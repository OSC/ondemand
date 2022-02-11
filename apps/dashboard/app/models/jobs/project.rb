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

  attr_reader :dir

  def initialize(args = {})
    # raise StandardError, "#{dir} is not a directory" unless File.directory?(dir.to_s)

    @dir = args.fetch(:dir, nil)
  end

  def config_dir
    Rails.logger.debug("The dir: #{dir}")
    Pathname.new("#{​​​dir}​​​/.ondemand").tap {​ |p| p.mkpath unless p.exist?​ }
   end

  def manifest_path
    "#{config_dir}/manifest.yml"
  end

  def manifest
    @manifest ||= Manifest.load(manifest_path)
  end

  def save!
    # for the @project.save api you see in frame renderer
    Dir.mkdir(Jobs::Project.dataroot.join(dir)) # assertions later for what willing to accept
  end

  def destroy!
    #FileUtils.rmdir "#{dir}/.ondemand"
    FileUtils.rmdir(Jobs::Project.dataroot.join(dir))
  end
end
