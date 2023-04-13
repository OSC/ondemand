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
      lookup_table.map { |id, _directory| id }
                  .map(&:to_i)
                  .concat([0]) # could be the first project
                  .max + 1
    end

    def all
      lookup_table.map do |id, directory|
        Project.new({ id: id, directory: directory })
      end
    end

    def find(id)
      opts = lookup_table.select do |lookup_id, _directory|
        lookup_id == id.to_i
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

  # the template you created this project from
  attr_accessor :template

  def initialize(attributes = {})
    if attributes.empty?
      @manifest = Manifest.new({})
    else
      @id = attributes.delete(:id)
      @directory = attributes.delete(:directory) || Project.dataroot.join(id.to_s)

      @manifest = Manifest.new(attributes).merge(Manifest.load(manifest_path))
    end
  end

  def save(attributes)
    if id.nil? && attributes.fetch(:id, nil).nil?
      message = 'Project ID must be set when saving.'
      errors.add(:save, message)
      Rails.logger.warn(message)
      return false
    end

    make_dir
    update(attributes)
  end

  def update(attributes)
    if valid_form_inputs?(attributes)
      new_manifest = Manifest.load(manifest_path)
      new_manifest = new_manifest.merge(attributes)

      if new_manifest.valid? && new_manifest.save(manifest_path) && add_to_lookup
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
    FileUtils.remove_dir(project_dataroot, force = true)
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

  private

  attr_reader :manifest

  def valid_form_inputs?(attributes)
    icon_pattern = %r{\Afa[bsrl]://[\w-]+\z}

    if !attributes[:icon].nil? && !attributes[:icon].match?(icon_pattern)
      errors.add(:icon, :invalid_format, message: 'Icon format invalid or missing')
      false
    elsif attributes[:icon].nil?
      attributes[:icon] = 'fas://cog'
      true
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
