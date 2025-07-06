# frozen_string_literal: true

class Workflow
  include ActiveModel::Model

  class << self
    def workflows_file(project_dir)
      workflows_dir = Pathname.new("#{project_dir}/.ondemand/workflows")
      # TODO: Later use <workflow_id>.yml to get list of all workflows
      file = workflows_dir.join("workflow.yml")

      FileUtils.mkdir_p(workflows_dir)
      FileUtils.touch(workflows_dir.join("workflow.yml")) unless file.exist?

      file
    end

    def all(project_id)
      project = Project.find(project_id)
      project_dir = project.directory
      f = File.read(workflows_file(project_dir))
      YAML.safe_load(f).to_h.map do |id, workflow_name|
        Workflow.new({ id: id, name: workflow_name })
      end
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{project_dir}/.ondemand/workflows/workflow.yml due to error #{e}")
      {}
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end

    def find(project_id, id)
      project = Project.find(project_id)
      project_dir = project.directory
      f = File.read(workflows_file(project_dir))
      opts = YAML.safe_load(f).to_h.select do |id, workflow_name|
        id == id.to_s
      end.map do |id, workflow_name|
        { id: id, name: workflow_name, project_id: project_id}
      end.first
      return nil if opts.nil?

      Workflow.new(opts)
    end
  end
  
  attr_reader :id, :name, :description, :project_id, :project_dir

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @project_id = attributes[:project_id]
    project = Project.find(@project_id)
    @project_dir = project.directory unless project.nil?
  end

  def to_h
    {
      :id => id,
      :name => name,
      :description => description,
    }
  end

  def save
    return false unless valid?(:create)

    # SET DEFAULTS
    @id = Workflow.next_id if id.blank?

    add_to_workflow(:save) && save_manifest(:save)
  end

  def save_manifest(operation)
    FileUtils.touch(manifest_file) unless manifest_file.exist?
    Pathname(manifest_file).write(to_h.deep_stringify_keys.compact.to_yaml)

    true
  rescue StandardError => e
    errors.add(operation, I18n.t('dashboard.jobs_project_save_error', path: manifest_file))
    Rails.logger.warn "Cannot save workflow manifest: #{manifest_file} with error #{e.class}:#{e.message}"
    false
  end

  def add_to_workflow(operation)
    f = File.read(Workflow.workflows_file(project_dir))
    new_table = YAML.safe_load(f).to_h.merge(Hash[id, name.to_s])
    File.write(Workflow.workflows_file(project_dir), new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(operation, "Cannot update workflow lookup file with error #{e.class}:#{e.message}")
    false
  end

  def collect_errors
    errors.map(&:message).join(', ')
  end

  def destroy!
    remove_from_lookup
    FileUtils.remove_entry(manifest_file, true)
    true
  end

  def remove_from_lookup
    f = File.read(Workflow.workflows_file(project_dir))
    new_table = YAML.safe_load(f).except(id)
    File.write(Workflow.workflows_file(project_dir), new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(:update, "Cannot update lookup file with error #{e.class}:#{e.message}")
    false
  end

  def manifest_file
    workflows_dir = Pathname.new("#{@project_dir}/.ondemand/workflows")
    file = workflows_dir.join("#{@id}.yml")
  end

  # TODO: Add logic to save the DAG relation between launchers like array of <launcher #1, launcher #2>

  # TODO: Add logic to save launcher pairs in the <workflow_id>.yml file and use it in def show() from workflow_controller

end