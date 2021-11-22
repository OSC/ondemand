# subclass for specific functionality
# is this bettter than my jobs.rb route? where I wasn't using ActiveRecord
# thought jeff said we didn't nmeed it, and files.rb doesn't use it 
# and traverses dirs which is what I'm trying to accomplish.
# Could use the Pathname class it looks like, and probably Dir as well...

# First goal, get the pwd to be something called by view to display in form for dir in a project.
# so when you click work in you see that directory in the Script location.

# Also need to list the various directories in the users projects space.
# Then you click that project space, which is a dir made of project name,
# and in that are scirpts to run for that, and you select them and then it autofills forms
# in some way, but you can also select the scirpt and use a form to change things, like even 
# the script name or to copy to a new scirpt name with the changes you make.

# look at old one and notice what can be factgored across templates maybe, or what you see i n
# general for what goes to slurm or a job manager etc. then use those as fields to insert and save with.
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