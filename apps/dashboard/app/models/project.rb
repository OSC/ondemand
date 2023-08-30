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
          directory: child_directory
        }

        Project.new(**opts)
      end
    end
  end

  attr_reader :directory, :id

  delegate :icon, :name, :description, to: :manifest

  validates :name, presence: { message: :required }, on: [:create, :update]
  validates :id, :directory, :icon, presence: { message: :required }, on: [:update]
  validates :icon, format: { with: %r{\Afa[bsrl]://[\w-]+\z}, allow_blank: true, message: :format }, on: [:create, :update]
  validates :directory, exclusion: { in: [Project.dataroot.to_s], message: :invalid }, on: [:create, :update]
  validate :project_directory_validation, on: [:create]

  # the template you created this project from
  attr_accessor :template

  def initialize(attributes = {})
    @id = attributes.delete(:id)
    @directory = attributes.delete(:directory)
    @directory = File.expand_path(@directory) unless @directory.blank?

    @manifest = directory.blank? ? Manifest.new({} ) : Manifest.new(attributes).merge(Manifest.load(manifest_path))
  end

  def save
    make_dir

    if manifest.valid? && manifest.save(manifest_path) && add_to_lookup
      true
    else
      errors.add(:save, I18n.t('dashboard.jobs_project_save_error', path: manifest_path))
      false
    end
  end

  def create(attributes)
    @id = attributes.delete(:id)
    @directory = attributes.delete(:directory)
    @directory = File.expand_path(@directory) unless @directory.blank?

    @manifest = manifest.merge(attributes)

    return valid?(:create)
  end

  def set_defaults
    @id = Project.next_id if id.blank?
    @directory = Project.dataroot.join(id.to_s).to_s if directory.blank?
    @manifest = manifest.merge({ icon: 'fas://cog' }) if icon.blank?
  end

  def update(attributes)
    @manifest = manifest.merge(attributes)

    return valid?(:update)
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
    if directory.to_s.include?(Project.dataroot.to_s)
      FileUtils.remove_dir(project_dataroot, force = true)
    else
      FileUtils.remove_dir(configuration_directory, force = true)
    end
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
    errors.map do |field_error|
      field_error.message()
    end.join(', ')
  end

  private

  attr_reader :manifest

  def make_dir
    project_dataroot.mkpath         unless project_dataroot.exist?
    configuration_directory.mkpath  unless configuration_directory.exist?
  rescue StandardError => e
    errors.add(:make_directory, "Failed to make directory: #{e.message}")
  end

  def project_directory_validation
    if !directory.blank? && Project.lookup_table.map { |_id, directory| directory }.map(&:to_s).include?(directory.to_s)
      errors.add(:directory, :used)
    end
  end
end
