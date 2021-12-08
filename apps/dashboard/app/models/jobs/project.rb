class Jobs::Project

  def self.stat(dir)
    # need to get:
    # { name: path.basename 
    # directory: path.stat.directory }
    #hash back for ERB to work.
    path = Pathname.new(dir)
    {
      name: path.basename,
      directory: path.stat.directory?
    }
  end

  def ls
    dir_contents = files
    dir_contents.each_child.map do |path|
      Jobs::Project.stat(path)
    end
  end


  def pwd
    @pwd = Pathname.new(Dir.pwd)
  end

  def files
    @files = Dir.entries(pwd)
  end
end
