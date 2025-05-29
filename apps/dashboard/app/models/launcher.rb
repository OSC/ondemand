# frozen_string_literal: true

class Launcher
  include ActiveModel::Model
  include JobLogger

  class ClusterNotFound < StandardError; end

  attr_reader :title, :id, :created_at, :project_dir, :smart_attributes

  class << self
    def launchers_dir(project_dir)
      Pathname.new("#{project_dir}/.ondemand/launchers")
    end

    def find(id, project_dir)
      path = Launcher.path(project_dir, id)
      file = launcher_form_file(path)
      Launcher.from_yaml(file, project_dir)
    end

    def all(project_dir)
      Dir.glob("#{launchers_dir(project_dir).to_s}/*/form.yml").map do |file|
        Launcher.from_yaml(file, project_dir)
      end.compact.sort_by do |s|
        s.created_at
      end
    end

    def from_yaml(file, project_dir)
      contents = File.read(file)
      raw_opts = YAML.safe_load(contents)

      opts = raw_opts.to_h
      opts.merge!({ id: File.basename(File.dirname(file)) })
      opts.merge!({ project_dir: project_dir.to_s })

      new(opts)
    rescue StandardError, Errno::ENOENT => e
      Rails.logger.warn("Did not find launcher due to error #{e}")
      nil
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end

    def clusters?
      cluster_attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters', {})
      cluster_attribute.select_choices(hide_excludable: false).any?
    end

    def scripts?(project_dir)
      script_attribute = SmartAttributes::AttributeFactory.build('auto_scripts', { directory: project_dir })
      script_attribute.select_choices(hide_excludable: false).any?
    end
  end

  ID_REX = /\A\w{8}\Z/.freeze

  validates(:id, format: { with: ID_REX, message: "ID does not match #{Launcher::ID_REX.inspect}" }, on: [:save])

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access

    @project_dir = opts[:project_dir] || raise(StandardError, 'You must set the project directory')
    @id = opts[:id].to_s.match?(ID_REX) ? opts[:id].to_s : Launcher.next_id
    @title = opts[:title].to_s
    @created_at = opts[:created_at]
    sm_opts = {
      form:       opts[:form] || [],
      attributes: opts[:attributes] || {}
    }

    add_required_fields(**sm_opts)
    # add defaults if it's a brand new launcher with only title and directory.
    add_default_fields(**sm_opts) if opts.size <= 2
    @smart_attributes = build_smart_attributes(**sm_opts)
  end

  def build_smart_attributes(form: [], attributes: {})
    form.map do |form_item_id|
      attrs = attributes[form_item_id.to_sym].to_h.symbolize_keys
      cache_value = cached_values[form_item_id]
      attrs[:value] = cache_value if cache_value.present?
      SmartAttributes::AttributeFactory.build(form_item_id, attrs)
    end
  end

  def to_yaml
    attributes = smart_attributes.each_with_object({}) do |sm, hash|
      hash[sm.id.to_s] = sm.options_to_serialize
    end.deep_stringify_keys

    hsh = { 'title' => title, 'created_at' => created_at }
    hsh.merge!({ 'form' => smart_attributes.map { |sm| sm.id.to_s } })
    hsh.merge!({ 'attributes' => attributes })
    hsh.to_yaml
  end

  def to_h
    {}.tap do |hsh|
      instance_variables.each do |var|
        hsh[var] = instance_variable_get(var)
      end
    end
  end
  alias inspect to_h

  def quick_launch_params
    smart_attributes.map { |attr| ["launcher[#{attr.id}]", attr.value] }.to_h
  end

  # Delegate methods to smart_attributes' getter
  #
  # @param method_name the method name called
  # @param arguments the arguments to the call
  # @param block an optional block for the call
  def method_missing(method_name, *arguments, &block)
    # not a bug here, we want =, not ==
    if /^(?<id>[^=]+)$/ =~ method_name.to_s && (attribute = self[id])
      attribute.value
    else
      nil
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    (/^(?<id>[^=]+)$/ =~ method_name.to_s && self[id]) || super
  end

  def original_parameter(string)
    match = /([\w_]+)_(?:min|max|exclude|fixed)/.match(string)
    match[1]
  end

  # Find attribute in list using the id of the attribute
  # @param id [Object] id of attribute object
  # @return [SmartAttribute::Attribute, nil] attribute object if found
  def [](id)
    smart_attributes.detect { |attribute| attribute == id }
  end

  def []=(_id, value)
    smart_attributes.append(value)
  end

  def save
    return false unless valid?(:save)

    @created_at = Time.now.to_i if @created_at.nil?
    path = Launcher.path(project_dir, id)

    path.mkpath unless path.exist?
    File.write(Launcher.launcher_form_file(path), to_yaml)

    true
  rescue StandardError => e
    errors.add(:save, e.message)
    Rails.logger.warn("Cannot save launcher due to error: #{e.class}:#{e.message}")
    false
  end

  def destroy
    return true unless id
    path = Launcher.path(project_dir, id)
    FileUtils.remove_dir(Launcher.path(project_dir, id)) if path.exist?
    true
  rescue StandardError => e
    errors.add(:destroy, e.message)
    Rails.logger.warn("Cannot delete launcher #{id} due to error: #{e.class}:#{e.message}")
    false
  end

  def update(params)
    # reset smart attributes becuase the user could have removed some fields
    @smart_attributes = []

    # deal with things that would be in the 'form' section first to initialize
    # the individual smart attributes
    update_form(params)
    update_attributes(params)
  end

  def submit(options)
    cluster_id =  if options.has_key?(:auto_batch_clusters)
                    options[:auto_batch_clusters]
                  else
                    smart_attributes.find { |sm| sm.id == 'auto_batch_clusters' }.value.to_sym
                  end
    adapter = adapter(cluster_id).job_adapter

    render_format = adapter.class.name.split('::').last.downcase

    job_script = OodCore::Job::Script.new(**submit_opts(options, render_format))

    job_id = Dir.chdir(project_dir) do
      adapter.submit(job_script, **dependency_helper(options))
    end
    update_job_log(job_id, cluster_id.to_s)
    write_job_options_to_cache(options)

    job_id
  rescue StandardError => e
    errors.add(:submit, e.message)
    Rails.logger.error("ERROR: #{e.class} - #{e.message}")
    nil
  end

  def dependency_helper(options)
    {
      after: Array(options[:after]),
      afterok: Array(options[:afterok]),
      afternotok: Array(options[:afternotok]),
      afterany: Array(options[:afterany])
    }
  end

  def create_default_script
    return false if Launcher.scripts?(project_dir) || default_script_path.exist?

    script_content = <<~DEFAULT_SCRIPT
      #!/bin/bash
      # Sample script to configure project defaults. Delete when other scripts are available.
      echo "Hello World"
    DEFAULT_SCRIPT
    File.open(default_script_path, 'w+') { |file| file.write(script_content) }
    true
  end

  private

  def self.path(root_dir, launcher_id)
    unless launcher_id.to_s.match?(ID_REX)
      raise(StandardError, "#{launcher_id} is invalid. Does not match #{ID_REX.inspect}")
    end

    Pathname.new(File.join(Launcher.launchers_dir(root_dir), launcher_id.to_s))
  end

  def default_script_path
    Pathname(File.join(project_dir, 'hello_world.sh'))
  end

  def self.launcher_form_file(path)
    File.join(path, "form.yml")
  end

  # parameters you got from the controller that affect the attributes, not form.
  # i.e., mins & maxes you set in the form but get serialized to the 'attributes' section.
  def attribute_parameter?(name)
    ['min', 'max', 'exclude', 'fixed'].any? { |postfix| name && name.end_with?("_#{postfix}") }
  end

  # update the 'form' portion of the yaml file given 'params' from the controller.
  def update_form(params)
    params.reject do |key, _value|
      attribute_parameter?(key)
    end.each do |key, value|
      self[key.to_sym] = SmartAttributes::AttributeFactory.build(key, default_attributes(key)) if self[key.to_sym].nil?
      self[key.to_sym].value = value
    end
  end

  # update the 'attributes' portion of the yaml file given 'params' from the controller.
  def update_attributes(params)
    params.select do |key, _value|
      attribute_parameter?(key)
    end.each do |key, value|
      orig_param = original_parameter(key).to_sym
      self[orig_param].min = value if key.end_with?('_min') && !value.to_s.empty?
      self[orig_param].max = value if key.end_with?('_max') && !value.to_s.empty?
      self[orig_param].opts[:fixed] = true if key.end_with?('_fixed')

      if key.end_with?('_exclude')
        exclude_list = value.split(',').to_a
        self[orig_param].exclude_select_choices = exclude_list unless exclude_list.empty?
      end
    end
  end

  def default_attributes(smart_attr_id)
    case smart_attr_id
    when 'auto_scripts'
      { directory: project_dir }
    else
      {}
    end
  end

  def write_job_options_to_cache(opts)
    File.write(cache_file_path, opts.to_json)
  end

  def cache_file_path
    Pathname.new(File.join(Launcher.path(project_dir, id), "cache.json"))
  end

  def cache_file_exists?
    cache_file_path.exist?
  end

  def cached_values
    @cached_values ||= begin
      cache_file_path = OodAppkit.dataroot.join(Launcher.launchers_dir("#{project_dir}"), "#{id}_opts.json")
      cache_file_content = File.read(cache_file_path) if cache_file_path.exist?
      
      File.exist?(cache_file_path) ? JSON.parse(cache_file_content) : {}
    rescue => exception
      Rails.logger.error("Error reading cache file: #{exception.message}")
      {}
    end
  end

  def update_job_log(job_id, cluster)
    adapter = adapter(cluster).job_adapter
    info = adapter.info(job_id)
    job = HpcJob.from_core_info(info: info, cluster: cluster)

    upsert_job!(project_dir, job)
  end

  def submit_opts(options, render_format)
    smart_attributes.map do |sm|
      sm.value = options[sm.id.to_sym] unless sm.fixed?
      sm
    end.map do |sm|
      sm.submit(fmt: render_format)
    end.reduce(&:deep_merge)[:script].merge(
      # force some values for scripts like the 'workdir'. We could use auto
      # attributes, but this is not optional and not variable.
      {
        workdir: project_dir.to_s
      }
    )
  end

  def adapter(cluster_id)
    OodAppkit.clusters[cluster_id] || raise(ClusterNotFound, "Job specifies nonexistent '#{cluster_id}' cluster id.")
  end

  def add_required_fields(form: [], attributes: {})
    add_cluster_to_form(form: form, attributes: attributes)
    add_script_to_form(form: form, attributes: attributes)
  end

  def add_default_fields(form: [], **_args)
    Configuration.launcher_default_items.each do |default_item|
      form << default_item unless form.include?(default_item)
    end
  end

  def add_script_to_form(form: [], attributes: {})
    form << 'auto_scripts' unless form.include?('auto_scripts')

    dir = { directory: project_dir }
    attributes[:auto_scripts] = if attributes[:auto_scripts]
                                  attributes[:auto_scripts].merge(dir)
                                else
                                  dir
                                end
  end

  def add_cluster_to_form(form: [], attributes: {})
    return if form.include?('auto_batch_clusters')

    form << 'auto_batch_clusters'
  end
end
