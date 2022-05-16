# frozen_string_literal: true

class Project
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def all
      return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?

      dataroot.children.map do |d|
        # I think the issue is here, not the title method itself?
        Project.new({ :name => d.basename })
      rescue StandardError => e
        Rails.logger.warn("Didn't create project. #{e.message}")
        nil
      end.compact
    end

    def find(project_path)
      # previously the @proj_name kicked off a whole chain of events firing
      # now, we are just getting that manifest entry back only
      #
      full_path = dataroot.join(project_path)
      return nil unless full_path.directory?

      Project.new( name: full_path.basename )
    end

    def dataroot
      OodAppkit.dataroot.join('projects').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end
  end

  # validates :name, presence: true
  # validates :name, format: {
  #   with:    /\A[\w-]+\z/,
  #   message: I18n.t('dashboard.jobs_project_name_validation')
  # }

  # validates :icon, presence: true

  #attr_reader :manifest

  delegate :icon, :name, :description, to: :manifest

  def initialize(attributes = {})
    @manifest = Manifest.new(attributes)

    #@proj_name    = attributes.fetch(:name, nil).to_s
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
    #if project_name_valid?(attributes) && project_icon_valid?(attributes)
      new_manifest.valid? ? new_manifest.save(manifest_path) : false
    #else
    #  false
    #end
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
    !name.blank? ? name.to_s.downcase.tr_s(' ', '_') : ''
    #@proj_name.downcase.tr_s(' ', '_')
  end

  def title
    name.to_s.titleize
  end

  def manifest
    # attach a manifest attr to isolate and access manifest object
    @manifest ||= Manifest.load(manifest_path)
  end

  def manifest_path
    File.join(configuration_directory, 'manifest.yml') unless configuration_directory.nil?
  end

  private

  # def project_name_valid?(attributes)
  #   # check attributes[:name] being passed in update
  #   if !attributes[:name].match?(/\A[\w -]+\z/)
  #     errors.add(:name, :bad_format, message: I18n.t('dashboard.jobs_project_name_validation'))
  #     false
  #   else
  #     true
  #   end
  # end

  # def project_icon_valid?(attributes)
  #   unless attributes[:icon].match?(/\Afa[sbrl]:\/\/[\w-]+\z/)
  #     errors.add(:icon, :bad_format, message: 'Invalid icon name')
  #     false
  #   else
  #     true
  #   end
  # end
end
