# frozen_string_literal: true


class Project
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def all
      # return [Array] of all projects in ~/ondemand/data/sys/projects
      return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

      dataroot.children.map do |d|
        Project.new({ :dir => d.basename })
      rescue StandardError => e
        Rails.logger.warn("Didn't create project. #{e.message}")
        nil
      end.compact
    end

    def find(project_path)
      full_path = dataroot.join(project_path)
      return nil unless full_path.directory?

      Project.new({ dir: full_path })
    end

    def dataroot
      Rails.logger.debug("project path is: #{OodAppkit.dataroot.join('projects')}")

      OodAppkit.dataroot.join('projects').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end
  end

  validates :dir, presence: true
  validates :dir, format: {

    with: /\A[\w-]+\z/,
    message: 'Directory may only contain letters, digits, dashes, and underscores'
  }

  attr_reader :dir
  delegate :icon, :name, :description, to: :manifest

  def initialize(attributes = {})
    @dir            = attributes.fetch(:dir, nil).to_s
  end

  def save
    write_manifest
  rescue => error
    errors.add(:save, error.message)
    Rails.logger.error("ERROR: #{error.class} - #{error.message}")
    false
  end

  def update(attributes)
    manifest = Manifest.load(manifest_path)
    manifest = manifest.merge(attributes)
    manifest.valid? ? manifest.save(manifest_path) : false
  end

  def destroy!
    FileUtils.remove_dir(project_dataroot, force = true)
  end
  
  def manifest_path
    File.join(configuration_directory, 'manifest.yml')
  end

  def configuration_directory
    Pathname.new("#{project_dataroot}/.ondemand").tap { |path| path.mkpath unless path.exist? } 
  end

  def project_dataroot
    Project.dataroot.join(dir)
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def write_manifest
    manifest = Manifest.load(manifest_path)
    manifest = manifest.merge({ name: name, description: description, icon: icon })
    manifest.valid? ? manifest.save(manifest_path) : false
  end
end
