Rails.application.configure do
  config.x.ood.nav_categories = ENV['OOD_NAV_CATEGORIES'] ? ENV['OOD_NAV_CATEGORIES'].split(",") : ["Files", "Jobs", "Clusters", "Desktops"]
end

OodFilesApp.candidate_favorite_paths = OodFilesApp.new.paths_from_template(ENV['OOD_FILES_PATHS'], basename_filter: ENV['OOD_FILES_PATHS_BASENAME_FILTER'])
