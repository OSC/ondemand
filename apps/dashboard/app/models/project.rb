# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Project
  include ActiveModel::Model
  include ActiveModel::Validations

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

  attr_reader :directory, :id, :template

  delegate :icon, :name, :description, to: :manifest

  validates :name, presence: { message: :required }, on: [:create, :update]
  validates :id, :directory, :icon, presence: { message: :required }, on: [:update]
  validates :icon, format: { with: %r{\Afa[bsrl]://[\w-]+\z}, allow_blank: true, message: :format }, on: [:create, :update]
  validate :project_directory_invalid, on: [:create, :update]
  validate :project_directory_exist, on: [:create]
  validate :project_template_invalid, on: [:create]

  def initialize(attributes = {})
    @id = attributes.delete(:id)
    @directory = attributes.delete(:directory)
    @directory = File.expand_path(@directory) unless @directory.blank?
    @template = attributes.delete(:template)

    @manifest = Manifest.new(attributes)
    @manifest = @manifest.merge(Manifest.load(manifest_path)) unless new_record?
  end

  def new_record?
    return true if !id
    return true if !directory

    id && directory && !File.exist?(manifest_path)
  end

  def save(attributes={})
    @id = attributes.delete(:id) if attributes.key?(:id)
    @directory = attributes.delete(:directory) if attributes.key?(:directory)
    @directory = File.expand_path(@directory) unless @directory.blank?
    @manifest = manifest.merge(attributes)

    return false unless valid?(:create)

    # SET DEFAULTS
    @id = Project.next_id if id.blank?
    @directory = Project.dataroot.join(id.to_s).to_s if directory.blank?
    @manifest = manifest.merge({ icon: 'fas://cog' }) if icon.blank?

    make_dir && sync_template && store_manifest(:save)
  end

  def update(attributes)
    @manifest = manifest.merge(attributes)

    return false unless valid?(:update)

    store_manifest(:update)
  end

  def store_manifest(operation)
    if manifest.valid? && manifest.save(manifest_path) && add_to_lookup
      true
    else
      errors.add(operation, I18n.t('dashboard.jobs_project_save_error', path: manifest_path))
      false
    end
  end

  def add_to_lookup
    new_table = Project.lookup_table.merge(Hash[id, directory.to_s])
    File.write(Project.lookup_file, new_table.to_yaml)
    true
  rescue StandardError => e
    errors.add(:update, "Cannot update lookup file lookup file with error #{e.class}:#{e.message}")
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
    manifest.icon.sub('fas://', '')
  end

  def destroy!
    remove_from_lookup
    FileUtils.remove_dir(configuration_directory, true)
  end

  def configuration_directory
    Pathname.new("#{project_dataroot}/.ondemand")
  end

  def project_dataroot
    Project.dataroot.join(directory)
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

  private

  attr_reader :manifest

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

  # When copying a project from a template, we need new Script objects
  # that point to the _new_ project directory, not the template's directory.
  # This creates them _and_ serializes them to yml in the new directory.
  def save_new_scripts
    dir = Script.scripts_dir(template)
    Dir.glob("#{dir}/*/form.yml").map do |script_yml|
      Script.from_yaml(script_yml, project_dataroot)
    end.map do |script|
      saved_successfully = script.save
      errors.add(:save, script.errors.full_messages) unless saved_successfully

      saved_successfully
    end.none? do |saved_successfully|
      saved_successfully == false
    end
  end

  def rsync_args
    [
      'rsync', '-a', '--exclude', 'scripts/*',
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
    if !template.blank? && Project.templates.map { |template| template.directory.to_s }.exclude?(template.to_s)
      errors.add(:template, :invalid)
    end
  end
end
