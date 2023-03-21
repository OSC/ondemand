# frozen_string_literal: true

class Script
  include ActiveModel::Model

  attr_reader :title, :id, :project_dir, :smart_attributes

  class << self
    def scripts_dir(project_dir)
      @scripts_dir ||= Pathname.new("#{project_dir}/.ondemand/scripts").tap do |path|
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

    def reject_cluster?
      c.kubernetes? || c.linux_host? || c.systemd?
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

  private

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
