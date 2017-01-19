class NavConfig
  class << self
    attr_accessor :categories
    attr_accessor :show_develop_dropdown

    def show_home_link
      # only show home link if there are other pages
      # you can navigate to
      show_develop_dropdown
    end
  end
  self.categories = ["Files", "Jobs", "Clusters", "Desktops"]
  self.show_develop_dropdown = ENV['OOD_APP_SHARING'].present?
end
