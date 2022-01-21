class Jobs::Project 
  def self.all
    # return [Array] of all projects in ~/ondemand/data/sys/projects
    return [] unless dataroot.directory? && dataroot.executable? && dataroot.readable?
    
    dataroot.children.map do |d|
      Project.new(d)
    rescue StandardError => e
      Rails.logger.warn("Didn't create project. #{e.message}")
    end.compact
  end

  def self.dataroot
    Rails.logger.debug("project path is: #{OodAppkit.dataroot.join('projects')}")

    OodAppkit.dataroot.join('projects').tap do |p|
      p.mkpath unless p.exist?
    rescue StandardError => e
      Pathname.new('')
    end
  end

  attr_reader :dir

  def initialize(dir: nil)
    raise StandardError, "#{dir} is not a directory" unless dir File.directory?(directory.to_s)

    @dir = dir.to_s
  end

  def files
    #return [Array] of all files in current project dir
  end


  # .ondemand methods
  # recognize .ondemand dir in project space
  # return [String] with .ondemand directory
  def dot_ondemand_dir
    Dir.entries(:dir).find do |entry|
     entry =~ /^.ondemand/
    end
  end

  # remove .ondemand dir in project space
  def del_dot_ondemand_dir
    raise StandardError, "#{dot_ondemand_dir} does not exist yet." unless Dir.exists?(dot_ondemand_dir)
    
    Dir.rmdir(Jobs::Project.dataroot.join(dot_ondemand_dir))
  end

  # create .ondemand dir in project space
  def create_dot_ondemand_dir
    raise StandardError, "#{dot_ondemand_dir} already exists." if Dir.exists?(dot_ondemand_dir)

    Dir.mkdir(Jobs::Project.dataroot.join(dot_ondemand_dir))
  end

  # manifest methods

  
  # read contents of .ondemand dir and the manifest.yml file located there
  def project_manifest_reader
  end
end
