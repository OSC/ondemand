Rails.application.configure do
  config.x.ood.nav_categories = ENV['OOD_NAV_CATEGORIES'] ? ENV['OOD_NAV_CATEGORIES'].split(",") : ["Files", "Jobs", "Clusters", "Desktops"]
end
