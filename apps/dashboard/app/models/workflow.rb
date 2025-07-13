# frozen_string_literal: true

class Workflow
  include ActiveModel::Model

  class << self
    def workflow_dir(project_dir)
      dir = Pathname.new("#{project_dir}/.ondemand/workflows")
      FileUtils.mkdir_p(dir) unless dir.exist?
      dir
    end

    def find(id, project_dir)
      file = "#{workflow_dir(project_dir)}/#{id}.yml"
      Workflow.from_yaml(file, project_dir)
    end

    def all(project_dir)
      Dir.glob("#{workflow_dir(project_dir)}/*.yml").map do |file|
        Workflow.from_yaml(file, project_dir)
      end.compact.sort_by { |s| s.created_at }
    end

    def from_yaml(file, project_dir)
      contents = File.read(file)
      opts = YAML.safe_load(contents).deep_symbolize_keys
      new(opts)
    rescue StandardError, Errno::ENOENT => e
      Rails.logger.warn("Did not find workflow due to error #{e}")
      nil
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end
  end

  attr_reader :id, :name, :description, :project_dir, :created_at, :launcher_ids

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @project_dir = attributes[:project_dir]
    @created_at = attributes[:created_at]
    @launcher_ids = attributes[:launcher_ids] || []
  end

  def to_h
    {
      :id => id,
      :name => name,
      :description => description,
      :created_at => created_at,
      :project_dir => project_dir,
      :launcher_ids => launcher_ids
    }
  end

  def save
    return false unless valid?(:create)

    @created_at = Time.now.to_i if @created_at.nil?
    @id = Workflow.next_id if id.blank?
    save_manifest(:save)
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

  def collect_errors
    errors.map(&:message).join(', ')
  end

  def destroy!
    FileUtils.remove_entry(manifest_file, true)
    true
  end

  def manifest_file
    Workflow.workflow_dir(@project_dir).join("#{@id}.yml")
  end

  # TODO: Add logic to save the DAG relation between launchers like array of <launcher #1, launcher #2>

  # TODO: Add logic to save launcher pairs in the <workflow_id>.yml file and use it in def show() from workflow_controller

end