# frozen_string_literal: true

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

    def find(project_path)
      full_path = dataroot.join(project_path)
      return nil unless full_path.directory?

      Project.new({ name: full_path.basename })
    end

    def dataroot
      OodAppkit.dataroot.join('projects').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end
  end

  validates :directory, format: {
    with:    /\A[\w-]+\z/,
    message: 'Project name may only contain letters, digits, dashes, and underscores'
  }

  delegate :icon, :name, :description, to: :manifest

  def initialize(attributes = {})
    @proj_name    = attributes.fetch(:name, nil).to_s
  end

  # @params [Hash]
  # @return [Bool]
  def save(attributes)
    update(attributes)
  end

  # @params [Hash]
  # @return [Bool]
  def update(attributes)
    new_manifest = Manifest.load(manifest_path)
    new_manifest = new_manifest.merge(attributes)
    # validate new manifest name is acceptable for project name
    if project_name_valid?(attributes)
      new_manifest.valid? ? new_manifest.save(manifest_path) : false
    else
      false
    end
  end

  def destroy!
    FileUtils.remove_dir(project_dataroot, force = true)
  end

  def configuration_directory
    unless directory.blank?
      Pathname.new("#{project_dataroot}/.ondemand").tap { |path| path.mkpath unless path.exist? }
    end
  end

  def project_dataroot
    Project.dataroot.join(directory)
  end

  def directory
    @proj_name.downcase.tr_s(' ', '_')
  end

  def title
    name.titleize
  end

  def manifest
    # attach a manifest attr to isolate and access manifest object
    @manifest ||= Manifest.load(manifest_path)
  end

  def manifest_path
    File.join(configuration_directory, 'manifest.yml') unless configuration_directory.nil?
  end

  private

  def project_name_valid?(attributes)
    # check attributes[:name] being passed in update
    if !attributes[:name].match?(/\A[\w -]+\z/)
      errors.add(:name, :bad_format, message: 'Can only contain letters, underscores, digits and dashes')
      false
    else
      true
    end
  end
end
