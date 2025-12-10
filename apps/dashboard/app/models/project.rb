# frozen_string_literal: true
require 'zip'

# Project classes represent projects users create to run HPC jobs.
class Project
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include IconWithUri
  extend JobLogger

  class << self
    def from_directory(dir)
      # fetch "id" by opening .ondemand/manifest.yml
      manifest_path = Pathname("#{dir.to_s}/.ondemand/manifest.yml")
      contents = File.read(manifest_path)
      raw_opts = YAML.safe_load(contents)
      id = raw_opts["id"]
      Project.new({ id: id, directory: dir })
    rescue StandardError => e
      p = Project.new({ id: nil, directory: dir })
      p.errors.add(:create, "Cannot import project from #{dir} due to error #{e}")
      p
    end
  
    def lookup_file
      Pathname("#{dataroot}/.project_lookup").tap do |path|
        FileUtils.touch(path.to_s) unless path.exist?
      end
    end

    def lookup_table
      f = File.read(lookup_file)
      YAML.safe_load(f).to_h.reject do |_, dir|
        from_directory(dir).errors.present?
      end
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{dataroot}/.project_lookup due to error #{e}")
      {}
    end

    def import_to_lookup(imported_project)
      return false if imported_project.nil? || !imported_project.valid?

      Project.find(imported_project.id) ? true : imported_project.add_to_lookup(:import)
    end

    def next_id
      SecureRandom.alphanumeric(8).downcase
    end

    def all
      lookup_table.map do |id, directory|
        Project.new({ id: id, directory: directory })
      end
    end

    def find(id)
      opts = lookup_table.select do |lookup_id, _directory|
        lookup_id == id.to_s
      end.map do |lookup_id, directory|
        { id: lookup_id, directory: directory }
      end.first
      return nil if opts.nil?

      Project.new(opts)
    end

    def dataroot
      OodAppkit.dataroot.join('projects').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end

    def templates
      template_dir = Pathname.new(Configuration.project_template_dir)
      return [] if !template_dir.directory? || !template_dir.readable?

      template_dir.children.map do |child_directory|
        opts = {
          # Fake id is needed to make it a valid project
          id:        '__template',
          directory: child_directory
        }

        Project.new(**opts)
      end
    end

    # TODO: Use it to populate similar page as /projects where we will keep the imported projects
    def possible_imports
      Rails.cache.fetch('possible_imports', expires_in: 1.hour) do
        importable_directories
      end.reject{ |p| lookup_table.include?(p.id) }
    end

    private

    def importable_directories
      Configuration.shared_projects_root.map do |root|
        next unless File.exist?(root) && File.directory?(root) && File.readable?(root)

        Dir.each_child(root).map do |child|
          child_dir = "#{root}/#{child}"
          next unless File.directory?(child_dir) && File.readable?(child_dir)
          Dir.each_child(child_dir).map do |possible_project|
            Project.from_directory("#{child_dir}/#{possible_project}")
          end
        end.flatten
      end.flatten.compact.reject{ |p| p.errors.any? }
    end
  end

  attr_reader :id, :name, :description, :icon, :directory, :template, :files, :group_owner

  validates :name, presence: { message: :required }, on: [:create, :update]
  validates :id, :directory, :icon, presence: { message: :required }, on: [:update]
  validates :icon, format: { with: %r{\Afa[bsrl]://[\w-]+\z}, allow_blank: true, message: :format }, on: [:create, :update]
  validate :project_directory_invalid, on: [:create, :update]
  validate :project_directory_exist, on: [:create]
  validate :project_template_invalid, on: [:create]

  before_validation :add_icon_uri

  def initialize(attributes = {})
    @id = attributes[:id]
    update_attrs(attributes)
    @directory = Pathname.new(attributes[:directory].to_s)
    @template = attributes[:template]
    @group_owner = attributes[:group_owner] || directory_group_owner

    return if new_record?

    contents = File.read(manifest_path)
    raw_opts = YAML.safe_load(contents)
    update_attrs(raw_opts.symbolize_keys)
  end

  def to_h
    {
      :id => id,
      :name => name,
      :description => description,
      :icon => icon,
    }
  end

  def new_record?
    return true unless id
    return true unless directory.to_s.present?

    id && directory.to_s.present? && !File.exist?(manifest_path)
  end

  def save
    return false unless valid?(:create)

    # SET DEFAULTS
    @id = Project.next_id if id.blank?
    @directory = Pathname.new(Project.dataroot.join(id.to_s)) if directory.blank?
    @directory = Pathname.new(Project.dataroot.join(directory)) if directory.relative?

    @icon = 'fas://cog' if icon.blank?

    make_root && update_permission && make_dir && sync_template && store_manifest(:save)
  end

  def update(attributes)
    update_attrs(attributes)

    return false unless valid?(:update)

    store_manifest(:update)
  end

  def store_manifest(operation)
    save_manifest(operation) && add_to_lookup(operation)
  end

  def save_manifest(operation)
    manifest_path.write(to_h.deep_stringify_keys.compact.to_yaml)

    true
  rescue StandardError => e
    errors.add(operation, I18n.t('dashboard.jobs_project_save_error', path: manifest_path.to_s))
    Rails.logger.warn "Cannot save project manifest: #{manifest_path} with error #{e.class}:#{e.message}"
    false
  end

  def add_to_lookup(operation)
    new_table = Project.lookup_table.merge(Hash[id, directory.to_s])
    File.write(Project.lookup_file, new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(operation, "Cannot update lookup file with error #{e.class}:#{e.message}")
    false
  end

  def remove_from_lookup
    new_table = Project.lookup_table.except(id)
    File.write(Project.lookup_file, new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(:update, "Cannot update lookup file with error #{e.class}:#{e.message}")
    false
  end

  def private?
    directory.to_s.start_with?(CurrentUser.home)
  end
  
  def directory_group_owner
    if directory.to_s.present? && directory.grpowned?
      Etc.getgrgid(directory.stat.gid).name
    else
      nil
    end
  end

  def chgrp_directory
    return true if private? || group_owner == directory_group_owner

    begin
      group_gid = group_owner.nil? ? nil : Etc.getgrnam(group_owner).gid
      FileUtils.chown(nil, group_gid, directory)
    rescue StandardError => e
      errors.add(:save, "Unable to set group with error #{e.class}:#{e.message}")
      false
    end
  end

  def editable? 
    File.writable?(manifest_path)
  end
  
  def icon_class
    # rails will prepopulate the tag with fa- so just the name is needed
    icon.sub('fas://', '')
  end

  def destroy!
    remove_from_lookup
    FileUtils.remove_dir(configuration_directory, true)
  end

  def configuration_directory
    directory.join('.ondemand')
  end

  def title
    name.to_s.titleize
  end

  def manifest_path
    configuration_directory.join('manifest.yml')
  end

  def collect_errors
    errors.map(&:message).join(', ')
  end

  def size
    if directory.exist?
      o, e, s = Open3.capture3('timeout', "#{Configuration.project_size_timeout}s", 'du', '-s', '-b', directory.to_s)
      o.split('/')[0].to_i
    end
  end

  def jobs
    Project.jobs(directory)
  end

  def active_jobs
    jobs.reject(&:completed?)
  end

  def completed_jobs
    jobs.select(&:completed?)
  end

  def job(job_id, cluster)
    cached_job = jobs.detect { |j| j.id == job_id && j.cluster == cluster }
    return cached_job if cached_job.completed?

    info = adapter(cluster).info(job_id)
    job = HpcJob.from_core_info(info: info, cluster: cluster)
    Project.upsert_job!(directory, job)
    job
  end

  def remove_logged_job(job_id, cluster)
    old_job = jobs.detect { |j| j.id == job_id && j.cluster == cluster }
    Project.delete_job!(directory, old_job)

    jobs.none? { |j| j.id == job_id && j.cluster == cluster }
  end

  def adapter(cluster_id)
    cluster = OodAppkit.clusters[cluster_id] || raise(StandardError, "Job specifies nonexistent '#{cluster_id}' cluster id.")
    cluster.job_adapter
  end

  def readme_path
    file = Dir.glob("#{directory.to_s}/README.{md,txt}").first.to_s
    File.readable?(file) ? file : nil
  end

  def zip_to_template
    zip_file = directory.join('project.zip')
    FileUtils.rm(zip_file) if File.exist?(zip_file)
    Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
      files.each do |file_name|
        file_path = directory.join(file_name)
        zipfile.add(file_name, file_path.to_s) if File.exist?(file_path)
      end
    end
    zip_file
  end

  private

  def update_attrs(attributes)
    [:name, :description, :icon, :files].each do |attribute|
      instance_variable_set("@#{attribute}".to_sym, attributes.fetch(attribute, ''))
    end
  end

  def make_root
    directory.mkpath unless directory.exist?
    true
  rescue StandardError => e
    errors.add(:save, "Failed to initialize project directory: #{e.message}")
    false
  end

  def make_dir
    configuration_directory.mkpath  unless configuration_directory.exist?
    workflow_directory = Workflow.workflow_dir(directory)
    workflow_directory.mkpath unless workflow_directory.exist?
    logfile_path = JobLogger::JobLoggerHelper.log_file(directory)
    FileUtils.touch(logfile_path.to_s) unless logfile_path.exist?
    true
  rescue StandardError => e
    errors.add(:save, "Failed to make directory: #{e.message}")
    false
  end

  def update_permission
    directory.chmod(0750)
    chgrp_directory
  rescue StandardError => e
    errors.add(:save, "Failed to update permissions of the directory: #{e.message}")
    false
  end

  def sync_template
    return true if template.blank?

    # Sync the template files over
    oe, s = Open3.capture2e(*rsync_args)
    raise oe unless s.success?

    save_new_launchers
  rescue StandardError => e
    errors.add(:save, "Failed to sync template: #{e.message}")
    false
  end

  # When copying a project from a template, we need new Launcher objects
  # that point to the _new_ project directory, not the template's directory.
  # This creates them _and_ serializes them to yml in the new directory.
  def save_new_launchers
    dir = Launcher.launchers_dir(template)
    Dir.glob("#{dir}/*/form.yml").map do |launcher_yml|
      Launcher.from_yaml(launcher_yml, directory.to_s)
    end.map do |launcher|
      saved_successfully = launcher.save
      errors.add(:save, launcher.errors.full_messages) unless saved_successfully

      saved_successfully
    end.all? do |saved_successfully|
      saved_successfully == true
    end
  end

  def rsync_args
    [
      'rsync', '-rltp',
      '--exclude', 'launchers/*',
      '--exclude', '.ondemand/job_log.yml',
      "#{template}/", directory.to_s
    ]
  end

  def project_directory_exist
    if !directory.blank? && Project.lookup_table.map { |_id, directory| directory }.map(&:to_s).include?(directory.to_s)
      errors.add(:directory, :used)
    end
  end

  def project_directory_invalid
    if !directory.blank? && Project.dataroot == directory
      errors.add(:directory, :invalid)
    end
  end

  def project_template_invalid
    # This validation is to prevent the template directory being manipulated in the form.
    return if template.blank?

    template_path = Pathname.new(template)
    errors.add(:template, :invalid) if Project.templates.map { |t| t.directory.to_s }.exclude?(template.to_s)
    errors.add(:template, :invalid) unless template_path.exist? && template_path.readable?
  end
end
