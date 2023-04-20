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
    rescue StandardError, Errno::ENOENT => e
      Rails.logger.warn("Did not find script due to error #{e}")
      nil
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
    @smart_attributes = build_smart_attributes(**sm_opts)
  end

  def build_smart_attributes(form: [], attributes: {})
    form.map do |form_item_id|
      attrs = attributes[form_item_id.to_sym].to_h.symbolize_keys
      value = cached_values[form_item_id]
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

    job_script = OodCore::Job::Script.new(**submit_opts(options, render_format))

    job_id = Dir.chdir(project_dir) do
      adapter.submit(job_script)
    end
    update_job_log(job_id, options[:cluster].to_s)
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

  def write_job_options_to_cache(opts)
    File.write(cache_file_path, opts.to_json)
  end

  def cache_file_path
    Pathname.new(project_dir).join(".ondemand/scripts/#{id}_opts.json")
    #Pathname.new("#{Script.scripts_dir(project_dir)}/#{id}_cache.json")
  end

  def cache_file_exists?
    cache_file_path.exist?
  end

  def cached_values
    @cached_values ||= begin
      cache_file_path = OodAppkit.dataroot.join(Script.scripts_dir("#{project_dir}"), "#{id}_opts.json")
      cache_file_content = File.read(cache_file_path) if cache_file_exists?
      cache = File.exist?(cache_file_path) ? JSON.parse(cache_file_content) : {}
    rescue => exception
      Rails.logger.warn("Cache values error: #{exception}")
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
