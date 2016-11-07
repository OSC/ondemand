Rails.application.configure do
  config.x.ood.nav_categories = ENV['OOD_NAV_CATEGORIES'] ? ENV['OOD_NAV_CATEGORIES'].split(",") : ["Files", "Jobs", "Clusters", "Desktops"]

  #TODO: determine how to configure this via ENV
  projects = User.new.groups.map(&:name).grep(/^P./)
  config.x.ood.files_other_paths = projects.map { |p| Pathname.new("/fs/project/#{p}") }
  config.x.ood.files_other_paths << Pathname.new("/fs/scratch/#{User.new.name}")
  config.x.ood.files_other_paths << Pathname.new("/fs/scratch/#{projects.first}")
end
