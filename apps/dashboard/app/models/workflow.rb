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

  # TODO: Remove launcher_ids, source_ids, target_ids and use metadata only
  attr_reader :id, :name, :description, :project_dir, :created_at, :launcher_ids, :source_ids, :target_ids, :metadata

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @project_dir = attributes[:project_dir]
    @created_at = attributes[:created_at]
    @launcher_ids = attributes[:launcher_ids] || []
    @source_ids = attributes[:source_ids] || []
    @target_ids = attributes[:target_ids] || []
    @metadata = attributes[:metadata] || {}
  end

  def to_h
    {
      :id => id,
      :name => name,
      :description => description,
      :created_at => created_at,
      :project_dir => project_dir,
      :launcher_ids => launcher_ids,
      :source_ids => source_ids,
      :target_ids => target_ids,
      :metadata => metadata
    }
  end

  def save
    return false unless valid?(:create)

    if @project_dir.nil?
      errors.add(:save, "I18n.t('dashboard.jobs_project_directory_error')")
      return false
    end

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

  def update(attributes, override = false)
    update_attrs(attributes, override)
    return false unless valid?(:update)

    save_manifest(:update)
  end

  def update_attrs(attributes, override = false)
    [:name, :description, :launcher_ids, :metadata].each do |attribute|
      next unless override || attributes.key?(attribute)
      instance_variable_set("@#{attribute}".to_sym, attributes.fetch(attribute, ''))
    end
  end

  def submit(attributes = {})
    graph = Dag.new(attributes)
    if graph.has_cycle
      errors.add("Submit", "Specified edges form a cycle not directed-acyclic graph")
      return false
    end
    dependency = graph.dependency
    order = graph.order
    Rails.logger.info("Dependency list created by DAG #{dependency}")
    Rails.logger.info("Order in which launcher got submitted #{order}")

    all_launchers = Launcher.all(attributes[:project_dir])
    job_id_hash = {}  # launcher-job_id hash

    for id in order
      launcher = all_launchers.find { |l| l.id == id }
      unless launcher
        Rails.logger.warn("No launcher found for id #{id}, skipping...")
        next
      end
      dependent_launchers = dependency[id] || []

      begin
        jobs = dependent_launchers.map { |id| job_id_hash[id] }.compact
        opts = submit_launcher_params(launcher, jobs).to_h.symbolize_keys
        job_id = launcher.submit(opts)
        if job_id.nil?
          Rails.logger.warn("Launcher #{id} with opts #{opts} did not return a job ID.")
        else
          job_id_hash[id] = job_id
        end
      rescue => e
        error_msg = "Launcher #{id} with opts #{opts} failed to submit. Error: #{e.class}: #{e.message}"
        errors.add("Submit", error_msg)
        Rails.logger.warn(error_msg)
      end
    end
  end

  def submit_launcher_params(launcher, dependent_jobs)
    launcher_data = launcher.smart_attributes.each_with_object({}) do |attr, hash|
      hash[attr.id.to_s] = attr.opts[:value]
    end
    launcher_data["afterok"] = Array(dependent_jobs)
    launcher_data
  end

end