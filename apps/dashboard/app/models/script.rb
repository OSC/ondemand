# frozen_string_literal: true

class Script
  include ActiveModel::Model

  class ClusterNotFound < StandardError; end

  attr_reader :title, :id, :created_at, :project_dir, :smart_attributes

  class << self
    def scripts_dir(project_dir)
      Pathname.new("#{project_dir}/.ondemand/scripts").tap do |path|
        path.mkpath unless path.exist?
      end
    end

    def find(id, project_dir)
      script_path = Script.script_path(project_dir, id)
      file = script_form_file(script_path)
      Script.from_yaml(file, project_dir)
    end

    def all(project_dir)
      Dir.glob("#{scripts_dir(project_dir).to_s}/*/form.yml").map do |file|
        Script.from_yaml(file, project_dir)
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
      Rails.logger.warn("Did not find script due to error #{e}")
      nil
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end

    def clusters?
      cluster_attribute = SmartAttributes::AttributeFactory.build('auto_batch_clusters', {})
      cluster_attribute.select_choices(hide_excludable: false).any?
    end
  end

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access

    @project_dir = opts[:project_dir] || raise(StandardError, 'You must set the project directory')
    @id = opts[:id]
    @title = opts[:title].to_s
    @created_at = opts[:created_at]
    sm_opts = {
      form:       opts[:form] || [],
      attributes: opts[:attributes] || {}
    }

    add_required_fields(**sm_opts)

    @smart_attributes = build_smart_attributes(**sm_opts)
  end

  def build_smart_attributes(form: [], attributes: {})
    attrs = form.map do |form_item_id|
      attrs = attributes[form_item_id.to_sym].to_h.symbolize_keys
      cache_value = cached_values[form_item_id]
      attrs[:value] = cache_value if cache_value.present?
      SmartAttributes::AttributeFactory.build(form_item_id, attrs)
    end

    attrs
  end

  def to_yaml
    attributes = smart_attributes.each_with_object({}) do |sm, hash|
      hash[sm.id.to_s] = sm.options_to_serialize
    end.deep_stringify_keys

    hsh = { 'title' => title, 'created_at' => created_at }
    hsh.merge!({ 'form' => smart_attributes.map { |sm| sm.id.to_s }.compact })
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
    @id = Script.next_id if @id.nil?
    @created_at = Time.now.to_i if @created_at.nil?
    script_path = Script.script_path(project_dir, id)
    script_path.mkpath unless script_path.exist?
    File.write(Script.script_form_file(script_path), to_yaml)

    true
  rescue StandardError => e
    errors.add(:save, e.message)
    Rails.logger.warn("Cannot save script due to error: #{e.class}:#{e.message}")
    false
  end

  def destroy
    return true unless id
    script_path = Script.script_path(project_dir, id)
    FileUtils.remove_dir(Script.script_path(project_dir, id)) if script_path.exist?
    true
  rescue StandardError => e
    errors.add(:destroy, e.message)
    Rails.logger.warn("Cannot delete script #{id} due to error: #{e.class}:#{e.message}")
    false
  end

  def update(params)
    # reset smart attributes because the user could have removed some fields
    @smart_attributes = []

    # deal with things that would be in the 'form' section first to initialize
    # the individual smart attributes
    update_form(params)
    update_attributes(params)
  end

  def submit(options)
    adapter = adapter(options[:auto_batch_clusters]).job_adapter
    render_format = adapter.class.name.split('::').last.downcase

    job_script = OodCore::Job::Script.new(**submit_opts(options, render_format))

    job_id = Dir.chdir(project_dir) do
      adapter.submit(job_script)
    end
    update_job_log(job_id, options[:auto_batch_clusters].to_s)
    write_job_options_to_cache(options)

    job_id
  rescue StandardError => e
    errors.add(:submit, e.message)
    Rails.logger.error("ERROR: #{e.class} - #{e.message}")
    nil
  end

  def most_recent_job_id
    most_recent_job['id']
  end

  def most_recent_job_cluster
    most_recent_job['cluster']
  end

  private

  def self.script_path(root_dir, script_id)
    Pathname.new(File.join(Script.scripts_dir(root_dir), script_id.to_s))
  end

  def self.script_form_file(script_path)
    File.join(script_path, "form.yml")
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
    Pathname.new(File.join(Script.script_path(project_dir, id), "cache.json"))
  end

  def cache_file_exists?
    cache_file_path.exist?
  end

  def cached_values
    @cached_values ||= begin
      cache_file_path = OodAppkit.dataroot.join(Script.scripts_dir("#{project_dir}"), "#{id}_opts.json")
      cache_file_content = File.read(cache_file_path) if cache_file_path.exist?
      
      File.exist?(cache_file_path) ? JSON.parse(cache_file_content) : {}
    rescue => exception
      Rails.logger.error("Error reading cache file: #{exception.message}")
      {}
    end
  end

  def most_recent_job
    job_data.sort_by do |data|
      data['submit_time']
    end.reverse.first.to_h
  end

  def update_job_log(job_id, cluster)
    new_job_data = job_data + [{
      'id'          => job_id,
      'submit_time' => Time.now.to_i,
      'cluster'     => cluster.to_s
    }]

    File.write(job_log_file.to_s, new_job_data.to_yaml)
  end

  def job_data
    @job_data ||= YAML.safe_load(File.read(job_log_file.to_s)).to_a
  end

  def job_log_file
    @job_log_file ||= Pathname.new(File.join(Script.script_path(project_dir, id), "job_history.log")).tap do |path|
      FileUtils.touch(path.to_s)
    end
  end

  def submit_opts(options, render_format)
    smart_attributes.map do |sm|
      sm.value = options[sm.id.to_sym]
      sm
    end.map do |sm|
      sm.submit(fmt: render_format)
    end.reduce(&:deep_merge)[:script]
  end

  def adapter(cluster_id)
    OodAppkit.clusters[cluster_id] || raise(ClusterNotFound, "Job specifies nonexistent '#{cluster_id}' cluster id.")
  end

  def add_required_fields(form: [], attributes: {})
    add_cluster_to_form(form: form, attributes: attributes)
    add_script_to_form(form: form, attributes: attributes)
  end

  def add_script_to_form(form: [], attributes: {})
    return if form.include?('auto_scripts')

    form << 'auto_scripts'
    attributes[:auto_scripts] = {
      directory: project_dir
    }
  end

  def add_cluster_to_form(form: [], attributes: {})
    return if form.include?('auto_batch_clusters')

    form << 'auto_batch_clusters'
  end
end
