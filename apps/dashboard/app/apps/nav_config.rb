class NavConfig
    class << self
      attr_accessor :categories, :show_only_specified_categories
      alias_method :show_only_specified_categories?, :show_only_specified_categories
      alias_method :categories_whitelist=, :show_only_specified_categories=
    end
    self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
    self.show_only_specified_categories = false
end
