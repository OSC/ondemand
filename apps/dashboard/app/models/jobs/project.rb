class Jobs::Project 
  include ActiveModel::Model

  class << self
    def all
      # return [Array] of all projects in ~/ondemand/data/sys/projects
      return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?
      
      dataroot.children.map do |d|
        Jobs::Project.new({:dir => d.to_s})
      rescue StandardError => e
        Rails.logger.warn("Didn't create project. #{e.message}")
        nil
      end.compact
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

  attr_accessor :dir

  def initialize(args = {})
    @dir = args.fetch(:dir, nil).to_s
  end

  def config_dir
    Pathname.new(Jobs::Project.dataroot.join("#{dir}/.ondemand")).tap { |p| p.mkpath unless p.exist? }
  end

  def manifest_path
    "#{config_dir}/manifest.yml"
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def save!
    # for the @project.save api you see in frame renderer
    FileUtils.mkdir(dir_dataroot) #unless Jobs::Project.dataroot.join(dir).exist?
  #rescue => e
    #Rails.logger.debug("This directory #{dir} already exists")
  end

  def destroy!
    #FileUtils.rmdir "#{dir}/.ondemand"
    FileUtils.rmdir(dot_ondemand)
  end

  def dot_ondemand
    Jobs::Project.dataroot.join("#{dir}/.ondemand")
  end

  def dir_dataroot
    Jobs::Project.dataroot.join(dir)
  end
end
