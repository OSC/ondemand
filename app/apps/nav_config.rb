class NavConfig
  class << self
    attr_accessor :categories
    attr_accessor :show_develop_dropdown
  end
  self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
  self.show_develop_dropdown = ENV['OOD_APP_DEVELOPMENT'].present?
end
