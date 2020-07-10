class NavConfig
    class << self
      attr_accessor :categories, :categories_allowlist
      alias_method :categories_allowlist?, :categories_allowlist
    end
    self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
    self.categories_allowlist = false
end
