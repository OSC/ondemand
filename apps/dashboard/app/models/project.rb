# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Project
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def all
      return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

      dataroot.children.map do |d|
        Project.new({ :name => d.basename })
      rescue StandardError => e
        Rails.logger.warn("Didn't create project. #{e.message}")
        nil
      end.compact
    end

    def find(project_pathname)
      from_directory(dataroot.join(project_pathname))
    end

    def dataroot
      OodAppkit.dataroot.join('projects').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end

    def from_directory(project_pathname)
      return nil unless project_pathname.directory? && project_pathname.executable? && project_pathname.readable?

      Project.new({ project_directory: project_pathname.basename })
    end
  end

  validates :directory, presence: true
  validates :name, format: {
    with:    /\A[\w-]+\z/,
    message: I18n.t('dashboard.jobs_project_name_validation')
  }

  attr_reader :directory

  delegate :icon, :name, :description, to: :manifest

  def initialize(attributes = {})
    @directory = attributes.delete(:project_directory) || attributes[:name].to_s.downcase.tr_s(' ', '_')
    @manifest  = Manifest.new(attributes).merge(Manifest.load(manifest_path))
  end

  def save(attributes)
    make_dir
    update(attributes)
  end

  def update(attributes)
    if valid_form_inputs?(attributes)
      new_manifest = Manifest.load(manifest_path)
      new_manifest = new_manifest.merge(attributes)

      if new_manifest.valid? && new_manifest.save(manifest_path)
        true
      else
        errors.add(:update, "Cannot save manifest to #{manifest_path}")
        false
      end
    else
      errors.add(:update, 'Invalid entry')
      false
    end
  end

  def destroy!
    FileUtils.remove_dir(project_dataroot, force = true)
  end

  def configuration_directory
    Pathname.new("#{project_dataroot}/.ondemand")
  end

  def scripts_dataroot
    configuration_directory.join('/scripts')
  end

  def scripts
    scripts_dataroot.children.map do |script_path|
      Script.new(script_path.to_s)
    end
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

  private

  attr_reader :manifest

  def valid_form_inputs?(attributes)
    icon_pattern = %r{\Afa[bsrl]://[\w-]+\z}
    name_pattern = /\A[\w-]+\z/
    if !attributes[:icon].nil? && !attributes[:icon].match?(icon_pattern)
      errors.add(:icon, :invalid_format, message: 'Icon format invalid or missing')
      false
    elsif !attributes[:name].match?(name_pattern)
      errors.add(:name, :invalid_format, message: 'Name format invalid')
      false
    else
      true
    end
  end

  def make_dir
    project_dataroot.mkpath         unless project_dataroot.exist?
    configuration_directory.mkpath  unless configuration_directory.exist?
  rescue StandardError => e
    errors.add(:make_directory, "Failed to make directory: #{e.message}")
  end
end
