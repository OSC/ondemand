class Jobs::Project
  def ls(dir)
    Pathname.new(dir).each_child.map do |path|
      Jobs::Project.stat(path)
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def self.stat(dir)
    path = Pathname.new(dir)
      {
        name: path.basename,
        directory: path.stat.directory?
      }
  end

  def pwd
    Dir.pwd
  end
end
