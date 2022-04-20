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
      Rails.logger.debug("project_path: #{project_path}")
      full_path = dataroot.join(project_path)
      Rails.logger.debug("full_path: #{full_path}")
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

  validates :dir, presence: true
  validates :dir, format: {
    with: /\A[\w-]+\z/,
    message: 'Directory may only contain letters, digits, dashes, and underscores'
  }

  attr_reader :name, :description
  
  delegate :icon, :name, :description, to: :manifest

  def initialize(attributes = {})
    @name         = attributes.fetch(:name, nil).to_s
    @description  = attributes.fetch(:description, nil).to_s
  end
 
  # @params [Hash] 
  # @return [Bool]
  def save(attributes)
    result = update(attributes)
    # errors.add(:save, 'Cannot save manifest') unless result
    unless result
      Rails.logger.debug("result is #{result}, need it to be true")
    end
    result
  end

  # @params [Hash] 
  # @return [Bool]
  def update(attributes)
    # only have side effects in update
    new_manifest = Manifest.load(manifest_path)
    new_manifest = manifest.merge(attributes)
    new_manifest.valid? ? new_manifest.save(manifest_path) : false
  end

  def destroy!
    FileUtils.remove_dir(project_dataroot, force = true)
  end

  def configuration_directory
    unless dir.blank?
      Pathname.new("#{project_dataroot}/.ondemand").tap { |path| path.mkpath unless path.exist? }
    end
  end

  def project_dataroot
    Project.dataroot.join(dir)
  end

  def dir
    @name.downcase.tr_s(' ', '_')
  end

  def title
    name.titleize
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def manifest_path
    File.join(configuration_directory, 'manifest.yml') unless configuration_directory.nil?
  end
end
