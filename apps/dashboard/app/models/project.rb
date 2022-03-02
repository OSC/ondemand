# frozen_string_literal: true


class Project
  include ActiveModel::Model

  validates :dir, presence: true
  validates :dir, format: {
    with: /[\w-]+\z/,
    message: 'Name may only contain letters, digits, dashes, and underscores'
  }

  validates :description, length: { maximum: 140 }

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

      OodAppkit.dataroot.join('projects').tap do |p|
        p.mkpath unless p.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end
  end

  attr_reader :dir, :description, :icon, :title

  def initialize(attributes = {})
    @dir            = attributes.fetch(:dir, nil).to_s
    @title          = attributes.fetch(:title, nil).to_s
    @description    = attributes.fetch(:description, nil).to_s
    @icon           = attributes.fetch(:icon, nil).to_s
  end

  def config_dir
    Pathname.new("#{absolute_dir}/.ondemand").tap { |p| p.mkpath unless p.exist? }
  end

  def absolute_dir
    Project.dataroot.join(dir)
  end

  def save!
    true
  end

  def update(attributes)
    @title          = attributes[:title] if attributes[:title]
    @description    = attributes[:description] if attributes[:description]
    @icon           = attributes[:icon] if attributes[:icon]

    if self.valid?
      write_manifeset
      true
    else
      false
    end
  end

  def destroy!
    FileUtils.remove_dir(absolute_dir, force = true)
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def metadata
    manifest.metadata
  end

  def manifest_path
    File.join(config_dir, 'manifest.yml')
  end

  def make_manifest
    File.new(manifest_path, 'w+') # try this: unless Dir.pwd != Project.dataroot
  end

  def name
    proj = dir.scan(/[\w-]+\z/)
    proj[0]
  end

  def write_manifeset
    manifest = Manifest.load(manifest_path)
    manifest = manifest.merge({ title: title, description: description, icon: icon })
    
    # manifest_path.exist? not working, method missing for the manifest_path
    manifest.save(manifest_path) unless ( title.blank? || description.blank? ) # || manifest_path.exist?
    true
  end
end
