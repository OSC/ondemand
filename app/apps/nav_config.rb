class NavConfig
  class << self
    attr_accessor :categories, :categories_whitelist
  end
  self.categories = ["Files", "Jobs", "Clusters", "Interactive Apps"]
  self.categories_whitelist = true
  def self.categories_whitelist?
      self.categories_whitelist
  end
end
