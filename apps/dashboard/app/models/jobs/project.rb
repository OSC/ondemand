class Jobs::Project
  self << class
    def all
      # return [Array] of all projects in ~/ondemand/data/sys/myjobs/projects
      Dir.children(base_path)
  end

  def base_path
      ENV['HOME'] + '/ondemand/data/sys/myjobs/projects/'
    end
  end

  attr_reader :dir

  def initialize
    @dir = dir.to_s
  end

  def files
    #return [Array] of all files in current project dir
  end
end
