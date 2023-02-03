# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :name, :project_id, presence: true

  attr_accessor :name, :project_id

  # Static methods go inside the self block
  class << self
    def all(project_id)
      project = Project.find(project_id)
      return [] unless project.project_dataroot.directory? && project.project_dataroot.executable? && project.project_dataroot.readable?

      project.project_dataroot.children.map do |d|
        Script.new({ name: d.basename.to_s, project_id: project_id }) if form?(d.basename.to_s)
      rescue StandardError => e
        Rails.logger.warn("Didn't create script. #{e.message}")
        nil
      end.compact
    end

    def form?(file_name)
      file_name.split('.').last(2).join('.') == 'yml.erb'
    rescue StandardError => e
      Rails.logger.error("Script form? ERR: #{e.message}")
      false
    end

    def destroy(project_id, file_name)
      project = Project.find(project_id)
      file_name = "#{project.project_dataroot}/#{file_name}.yml.erb"
      File.delete(file_name) if File.exist?(file_name)
    end
  end

  def initialize(attributes = {})
    @name = attributes[:name]
    @project_id = attributes[:project_id]
  end

  def project!
    Project.find(@project_id) unless @project_id.nil?
  end

  def create_file
    project = project!
    file_name = "#{project.project_dataroot}/#{@name}.yml.erb"
    if File.new(file_name, 'w')
      true
    else
      errors.add(:update, "Cannot script_create_file #{file_name}")
      false
    end
  end

  def save
    create_file
  end
end
