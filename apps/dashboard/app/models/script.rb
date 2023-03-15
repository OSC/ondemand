# frozen_string_literal: true

class Script
  include ActiveModel::Model

  attr_reader :title

  attr_reader :id

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
        .max || 0 + 1
    end
  end

  attr_reader :project_dir, :smart_attributes

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access

    @project_dir = opts[:project_dir] || raise(StandardError, 'You must set the project directory')
    @id = opts[:id]
    @title = opts[:title].to_s
    @smart_attributes = build_smart_attributes(opts[:form] || [], opts[:attributes] || {})
  end

  def build_smart_attributes(form_list, attribute_hash)
    form_list.map do |form_item_id|
      attrs = attribute_hash[form_item_id].to_h.symbolize_keys
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
  alias_method :inspect, :to_h

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
end
