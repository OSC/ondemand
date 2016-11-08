OodAppGroup.nav_categories = ENV['OOD_NAV_CATEGORIES'].split(",") if ENV['OOD_NAV_CATEGORIES']
OodFilesApp.candidate_favorite_paths = OodFilesApp.new.paths_from_template(ENV['OOD_FILES_PATHS'], basename_filter: ENV['OOD_FILES_PATHS_BASENAME_FILTER'])
