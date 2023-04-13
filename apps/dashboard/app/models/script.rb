# frozen_string_literal: true

class Script
  include ActiveModel::Model

  class ClusterNotFound < StandardError; end

  attr_reader :title, :id, :project_dir, :smart_attributes

  class << self
    def scripts_dir(project_dir)
      Pathname.new("#{project_dir}/.ondemand/scripts").tap do |path|
        path.mkpath unless path.exist?
      end
    end

    def find(id, project_dir)
      file = "#{scripts_dir(project_dir)}/#{id}.yml"
      Script.from_yaml(file, project_dir)
    end

    def all(project_dir)
      Dir.glob("#{scripts_dir(project_dir)}/*.yml").map do |file|
        Script.from_yaml(file, project_dir)
      end
    end

    def from_yaml(file, project_dir)
      contents = File.read(file)
      raw_opts = YAML.safe_load(contents)

      opts = raw_opts.to_h
      opts.merge!({ id: File.basename(file, '.yml') })
      opts.merge!({ project_dir: project_dir.to_s })

      new(opts)
    end

    def next_id(project_dir)
      all(project_dir)
        .map(&:id)
        .map(&:to_i)
        .prepend(0)
        .max + 1
    end

    def batch_clusters
      Rails.cache.fetch('script_batch_clusters', expires_in: 4.hours) do
        Configuration.job_clusters.reject do |c|
          reject_cluster?(c)
        end.map(&:id).map(&:to_s)
      end
    end

    def reject_cluster?(cluster)
      cluster.kubernetes? || cluster.linux_host? || cluster.systemd?
    end
  end

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access

    @project_dir = opts[:project_dir] || raise(StandardError, 'You must set the project directory')
    @id = opts[:id]
    @title = opts[:title].to_s
    sm_opts = {
      form:       opts[:form] || [],
      attributes: opts[:attributes] || {}
    }
    add_cluster_to_form(**sm_opts, clusters: Script.batch_clusters)

    # Use cached form values if they exist
    json_file_path = OodAppkit.dataroot.join(Script.scripts_dir("#{project_dir}/"), "#{id}_opts.json")
    #json_file_path = Rails.root.join('tmp', "#{@script.id}_opts.json")

    cached_values = File.exist?(json_file_path) ? JSON.parse(File.read(json_file_path)) : {}

    @smart_attributes = build_smart_attributes(**sm_opts, cached_values: cached_values)
  end

  def build_smart_attributes(form: [], attributes: {}, cached_values: {})
    form.map do |form_item_id|
      attrs = attributes[form_item_id.to_sym].to_h.symbolize_keys
      value = cached_values[form_item_id.to_s]
      attrs[:value] = value if value.present?
      SmartAttributes::AttributeFactory.build(form_item_id, attrs)
    end
  end

  def to_yaml
    { 'title' => title }.to_yaml
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
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    (/^(?<id>[^=]+)$/ =~ method_name.to_s && self[id]) || super
  end

  # Find attribute in list using the id of the attribute
  # @param id [Object] id of attribute object
  # @return [SmartAttribute::Attribute, nil] attribute object if found
  def [](id)
    smart_attributes.detect { |attribute| attribute == id }
  end

  def save
    @id = Script.next_id(project_dir)
    File.write("#{Script.scripts_dir(project_dir)}/#{id}.yml", to_yaml)

    true
  rescue StandardError => e
    errors.add(:save, e.message)
    Rails.logger.warn("Cannot save script due to error: #{e.class}:#{e.message}")
    false
  end

  def submit(options)
    adapter = adapter(options[:cluster]).job_adapter
    render_format = adapter.class.name.split('::').last.downcase

    # i think i need to look at these options to understand where this writes out
    job_script = OodCore::Job::Script.new(**submit_opts(options, render_format))

    job_id = Dir.chdir(project_dir) do
      adapter.submit(job_script)
    end
    update_job_log(job_id)

    job_id
  rescue StandardError => e
    errors.add(:submit, e.message)
    Rails.logger.error("ERROR: #{e.class} - #{e.message}")
    nil
  end

  def most_recent_job_id
    most_recent_job['id']
  end

  private

  def most_recent_job
    job_data.sort_by do |data|
      data['submit_time']
    end.reverse.first.to_h
  end

  def update_job_log(job_id)
    new_job_data = job_data + [{
      'id'          => job_id,
      'submit_time' => Time.now.to_i
    }]

    File.write(job_log_file.to_s, new_job_data.to_yaml)
  end

  def job_data
    @job_data ||= YAML.safe_load(File.read(job_log_file.to_s)).to_a
  end

  def job_log_file
    @job_log_file ||= Pathname.new("#{Script.scripts_dir(project_dir)}/#{id}_job_log").tap do |path|
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

  def write_cache_file(file)
    cache_file = filt.to_s
    cache_path = OodAppkit.dataroot.join(Project.dataroot, '.ondemand', 'script', '')
    File.write(cache)
  end

  def adapter(cluster_id)
    OodAppkit.clusters[cluster_id] || raise(ClusterNotFound, "Job specifies nonexistent '#{cluster_id}' cluster id.")
  end

  def add_cluster_to_form(form: [], attributes: {}, clusters: [])
    form.prepend('cluster') unless form.include?('cluster')

    attributes[:cluster] = if clusters.size > 1
                             select_clusters(clusters)
                           else
                             fixed_cluster(clusters)
                           end
  end

  def select_clusters(clusters)
    {
      widget:  'select',
      label:   'Cluster',
      options: clusters
    }
  end

  def fixed_cluster(clusters)
    {
      value: clusters.first.id.to_s,
      fixed: true
    }
  end
end
