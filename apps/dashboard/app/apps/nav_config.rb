class NavConfig
    class << self
      attr_accessor :categories, :categories_whitelist
      alias_method :categories_whitelist?, :categories_whitelist
    end
    self.categories = ["Apps", "Files", "Jobs", "Clusters", "Interactive Apps"]
    self.categories_whitelist = false
end
