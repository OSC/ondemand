class Jobs::Project
  def ls(dir)
    Pathname.new(dir).each_child.map do |path|
      Jobs::Project.stat(path)
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def self.stat(dir)
    path = Pathname.new(dir)
      {
        id: "dev-#{path.stat.dev}-inode-#{path.stat.ino}",
        name: path.basename,
        directory: path.stat.directory?,
        size: path.stat.size
      }
  end

  def pwd
    Dir.pwd
  end
end
