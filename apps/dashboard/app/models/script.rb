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
    @smart_attributes = opts[:smart_attributes] || {}
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
