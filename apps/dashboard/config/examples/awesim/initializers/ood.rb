# frozen_string_literal: true

# AweSim OOD config

OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add project space directories
  projects = User.new.groups.map(&:name).grep(/^P./)
  paths.concat projects.map { |p| Pathname.new("/fs/project/#{p}") }

  # add scratch space directories
  paths << Pathname.new("/fs/scratch/#{User.new.name}")
  paths.concat projects.map { |p| Pathname.new("/fs/scratch/#{p}") }
end

# don't show develop dropdown unless you are setup for app sharing
Configuration.app_development_enabled = UsrRouter.base_path.directory?
Configuration.app_sharing_facls_enabled = true

# uncomment if you want to revert to the old menu
# NavConfig.categories = ["Files", "Jobs", "Clusters", "Desktops", "Desktop Apps"]
