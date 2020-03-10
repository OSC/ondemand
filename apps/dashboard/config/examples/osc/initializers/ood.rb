OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add project space directories
  projects = User.new.groups.map(&:name).grep(/^P./)
  paths.concat projects.map { |p| Pathname.new("/fs/project/#{p}")  }

  # add scratch space directories
  paths << Pathname.new("/fs/scratch/#{User.new.name}")
  paths.concat projects.map { |p| Pathname.new("/fs/scratch/#{p}")  }
end



OodFilesApp.favorite_path_names.tap do |paths|
    
    projects = User.new.groups.map(&:name).grep(/^P./)
    projects.map { |p| paths[Pathname.new("/fs/project/#{p}")] = "Project" }
    
    paths[Pathname.new("/fs/scratch/#{User.new.name}")] = "Scratch"
    projects.map { |p| paths[Pathname.new("/fs/scratch/#{p}")] = "Scratch" }
    
end









# uncomment if you want to revert to the old menu
# NavConfig.categories = ["Files", "Jobs", "Clusters", "Desktops", "Desktop Apps"]
