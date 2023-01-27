# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  validates :name, :project_id, presence: true

  attr_accessor :name, :batch_connect_form, :project_id

  # Static methods go inside the self block
  class << self
    def all(project_id)
      @project = Project.find(project_id)
      return [] unless @project.project_dataroot.directory? && @project.project_dataroot.executable? && @project.project_dataroot.readable?

      @project.project_dataroot.children.map do |d|
        Script.new({ name: d.basename.to_s, project_id: project_id }) unless d.basename.to_s.start_with?('.')
      rescue StandardError => e
        Rails.logger.warn("Didn't create script. #{e.message}")
        nil
      end.compact
    end
  end

  def initialize(attributes = {})
    @name = attributes[:name]
    @project_id = attributes[:project_id]
    @batch_connect_form = attributes[:batch_connect_form]
  end

  def script_dataroot
    @project = Project.find(@project_id)
    @project.project_dataroot.join(@name)
  end

  def create_form_file
    file_name = "#{script_dataroot}/form.yml.erb"
    if File.new(file_name, 'w')
      true
    else
      errors.add(:update, "Cannot create #{file_name}")
      false
    end
  end

  def save
    make_dir
    create_form_file
  end

  def make_dir
    Rails.logger.debug('GWB make_dir')
    script_dataroot.mkpath unless script_dataroot.exist?
  rescue StandardError => e
    Rails.logger.debug("GWB make_dir error: #{e.message}")
    errors.add(:make_directory, "GWB Failed to make directory: #{e.message}")
  end
end
