# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Project
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include IconWithUri
  extend JobLogger

  class << self
    def lookup_file
      Pathname("#{dataroot}/.project_lookup").tap do |path|
        FileUtils.touch(path.to_s) unless path.exist?
      end
    end

    def lookup_table
      f = File.read(lookup_file)
      YAML.safe_load(f).to_h
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{dataroot}/.project_lookup due to error #{e}")
      {}
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
  end

  attr_reader :id, :name, :description, :icon, :directory, :template

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
    @directory = attributes[:directory]
    @directory = File.expand_path(@directory) unless @directory.blank?
    @template = attributes[:template]

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
    return true unless directory

    id && directory && !File.exist?(manifest_path)
  end

  def save
    return false unless valid?(:create)

    # SET DEFAULTS
    @id = Project.next_id if id.blank?
    @directory = Project.dataroot.join(id.to_s).to_s if directory.blank?
    @icon = 'fas://cog' if icon.blank?

    make_dir && sync_template && store_manifest(:save)
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
    Pathname(manifest_path).write(to_h.deep_stringify_keys.compact.to_yaml)

    true
  rescue StandardError => e
    errors.add(operation, I18n.t('dashboard.jobs_project_save_error', path: manifest_path))
    Rails.logger.warn "Cannot save project manifest: #{manifest_path} with error #{e.class}:#{e.message}"
    false
  end

  def add_to_lookup(operation)
    new_table = Project.lookup_table.merge(Hash[id, directory.to_s])
    File.write(Project.lookup_file, new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(operation, "Cannot update lookup file lookup file with error #{e.class}:#{e.message}")
    false
  end

  def remove_from_lookup
    new_table = Project.lookup_table.except(id)
    File.write(Project.lookup_file, new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(:update, "Cannot update lookup file lookup file with error #{e.class}:#{e.message}")
    false
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
    Pathname.new("#{project_dataroot}/.ondemand")
  end

  def project_dataroot
    Project.dataroot.join(directory.to_s)
  end

  def title
    name.to_s.titleize
  end

  def manifest_path
    File.join(configuration_directory, 'manifest.yml')
  end

  def collect_errors
    errors.map(&:message).join(', ')
  end

  def size
    if Dir.exist? project_dataroot
      o, e, s = Open3.capture3('timeout', "#{Configuration.project_size_timeout}s", 'du', '-s', '-b', project_dataroot.to_s)
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

  def adapter(cluster_id)
    cluster = OodAppkit.clusters[cluster_id] || raise(StandardError, "Job specifies nonexistent '#{cluster_id}' cluster id.")
    cluster.job_adapter
  end

  def readme_path
    file = Dir.glob("#{directory}/README.{md,txt}").first.to_s
    File.readable?(file) ? file : nil
  end

  private
  
  def update_attrs(attributes)
    [:name, :description, :icon].each do |attribute|
      instance_variable_set("@#{attribute}".to_sym, attributes.fetch(attribute, ''))
    end
  end

  def make_dir
    project_dataroot.mkpath         unless project_dataroot.exist?
    configuration_directory.mkpath  unless configuration_directory.exist?
    true
  rescue StandardError => e
    errors.add(:save, "Failed to make directory: #{e.message}")
    false
  end

  def sync_template
    return true if template.blank?

    # Sync the template files over
    oe, s = Open3.capture2e(*rsync_args)
    raise oe unless s.success?

    save_new_scripts
  rescue StandardError => e
    errors.add(:save, "Failed to sync template: #{e.message}")
    false
  end

  # When copying a project from a template, we need new Launcher objects
  # that point to the _new_ project directory, not the template's directory.
  # This creates them _and_ serializes them to yml in the new directory.
  def save_new_scripts
    dir = Launcher.scripts_dir(template)
    Dir.glob("#{dir}/*/form.yml").map do |script_yml|
      Launcher.from_yaml(script_yml, project_dataroot)
    end.map do |script|
      saved_successfully = script.save
      errors.add(:save, script.errors.full_messages) unless saved_successfully

      saved_successfully
    end.all? do |saved_successfully|
      saved_successfully == true
    end
  end

  def rsync_args
    [
      'rsync', '-rltp', '--exclude', 'scripts/*',
      "#{template}/", project_dataroot.to_s
    ]
  end

  def project_directory_exist
    if !directory.blank? && Project.lookup_table.map { |_id, directory| directory }.map(&:to_s).include?(directory.to_s)
      errors.add(:directory, :used)
    end
  end

  def project_directory_invalid
    if !directory.blank? && Project.dataroot.to_s == directory
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
