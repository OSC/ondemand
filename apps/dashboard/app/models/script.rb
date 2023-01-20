# frozen_string_literal: true

# Project classes represent projects users create to run HPC jobs.
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  # Due to manifest requirements, we will assume the following
  # - category will represent project
  # - subcategory will represent script type

  delegate :name, :description, :icon, :subcategory, :category, to: :manifest

  attr_reader :name, :description, :icon, :subcategory, :category, :manifest

  def initialize(attributes = {})
    Rails.logger.debug("GWB init attr: #{attributes.inspect}")
    @category = Project.find(attributes[:category])
    Rails.logger.debug("GWB init cat: #{@category.inspect}")
    @directory = attributes.delete(:script_directory) || attributes[:name].to_s.downcase.tr_s(' ', '_')
    @name = attributes[:name]
    @description = attributes[:description]
    @icon = attributes[:icon]
    @subcategory = attributes[:subcategory]
    @manifest = Manifest.new(attributes).merge(Manifest.load(manifest_path))
  end

  def save(attributes)
    make_dir
    update(attributes)
  end

  def all
    return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

    dataroot.children.map do |d|
      @name = d.basename
      Script.new({ :category => @category.name, :name => d.basename }) if !d.basename.nil? && File.file?(manifest_path)
    rescue StandardError => e
      Rails.logger.warn("Didn't create project. #{e.message}")
    end.compact
  end

  def find
    Rails.logger.debug("GWB SCRIPT PATH: #{@manifest.inspect}")
    # Script.new(@manifest)
    Script.new(
      {
        category: @category.name, name: @manifest.name, description: @manifest.description,
        icon: @manifest.icon, subcategory: @manifest.subcategory
      }
    )
  end

  def manifest_path_only
    "#{script_path}/.ondemand"
  end

  def manifest_path
    "#{script_path}/.ondemand/manifest.xml"
  end

  def script_path
    "#{dataroot}/#{name}"
  end

  def dataroot
    return_value = ''
    OodAppkit.dataroot.join("projects/#{project_directory}").tap do |path|
      path.mkpath unless path.exist?
      return_value = path
    rescue StandardError
      Pathname.new('')
    end

    return_value
  end

  def project_directory
    @category.directory
  end

  def update(attributes)
    if valid_form_inputs?(attributes)
      new_manifest = Manifest.load(manifest_path)
      new_manifest = new_manifest.merge(attributes)
      Rails.logger.debug("GWB update attributes: #{attributes.inspect}")
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

  def make_dir
    Rails.logger.debug("GWB make_dir: #{manifest_path_only}")
    Pathname.new(manifest_path_only).mkpath unless File.directory?(manifest_path_only)
  end

  def valid_form_inputs?(attributes)
    icon_pattern = %r{\Afa[bsrl]://[\w-]+\z}
    name_pattern = /\A[\w-]+\z/
    # if !attributes[:icon].nil? && !attributes[:icon].match?(icon_pattern)
    if 1 == 0
      errors.add(:icon, :invalid_format, message: 'Icon format invalid or missing')
      false
    elsif !attributes[:name].match?(name_pattern)
      errors.add(:name, :invalid_format, message: 'Name format invalid')
      false
    else
      true
    end
  end

end
