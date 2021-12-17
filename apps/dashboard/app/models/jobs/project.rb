class Jobs::Project
    def self.all
      # return [Array] of all projects in ~/ondemand/data/sys/myjobs/projects
      @projects_path = ENV['HOME'] + '/ondemand/data/sys/myjobs/projects/'
      Dir.children(@projects_path)
    end

  attr_reader :dir

  def initialize
    @dir = dir.to_s
  end

  def files
    #return [Array] of all files in current project dir
  end
end
