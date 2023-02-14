# frozen_string_literal: true

class Script
  include ActiveModel::Model

  attr_reader :title

  attr_reader :id

  class << self

    def all(project_dir)
      Dir.glob("#{Project.dataroot}/#{project_dir}/.ondemand/scripts/*.yml").map do |file|
        Script.from_yaml(file, project_dir)
      end
    end

    def from_yaml(file, project_dir)
      contents = File.read(file)
      opts = YAML.safe_load(contents).to_h
      opts.merge!({ id: File.basename(file, '.yml') })
      opts.merge!({ project_dir: project_dir.to_s })
      new(opts)
    end
    alias_method :from_yml, :from_yaml

    def next_id(project_dir)
      all(project_dir).map(&:id).map(&:to_i).max + 1
    end
  end

  def initialize(opts = {})
    opts = opts.to_h.with_indifferent_access

    @project_dir = opts[:project_dir] || raise(StandardError, 'You must set the project directory')
    @id = opts[:id]
    @title = opts[:title].to_s
  end

  def to_yaml
    { 'title' => title }.to_yaml
  end
  alias_method :to_yml, :to_yaml

  def to_h
    {}.tap do |hsh|
      instance_variables.each do |var|
        hsh[var] = instance_variable_get(var)
      end
    end
  end
  alias_method :inspect, :to_h

  def save
    save!
    true
  rescue StandardError => e
    errors.add(:save, e.message)
    Rails.logger.warn("Cannot save script due to error: #{e.class}:#{e.message}")
    false
  end

  def save!
    @id = Script.next_id(project_dir)
    File.write("#{Project.dataroot}/#{project_dir}/.ondemand/scripts/#{id}.yml", to_yaml)
  end

  private

  attr_reader :project_dir
end
