OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add project space directories
  projects = User.new.groups.map(&:name).grep(/^P./)
  paths.concat projects.map { |p| FavoritePath.new(Pathname.new("/fs/project/#{p}"), title: "Project")  }

  # add scratch space directories
  paths << FavoritePath.new(Pathname.new("/fs/scratch/#{User.new.name}"), title: "Scratch")
  paths.concat projects.map { |p| FavoritePath.new(Pathname.new("/fs/scratch/#{p}"), title: "Scratch")  }

  # add user favorite directories/files
  preferences = UserPref.new(User.new.dir)
  preferences.user_paths.each |path| do 
    paths << FavoritePath.new(Pathname.new(path))
  end

end
# uncomment if you want to revert to the old menu
# NavConfig.categories = ["Files", "Jobs", "Clusters", "Desktops", "Desktop Apps"]
