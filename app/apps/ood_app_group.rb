class OodAppGroup
  attr_accessor :apps, :title, :subtitle

  def initialize
    @apps = []
  end

  def has_apps?
    apps.count > 0
  end

  # Givin a list of owners, we will build a list of AppGroups
  # where each app group is a list of apps that user has shared
  def self.usr_groups(owners)
    Array(owners).map do |o|
      g = OodAppGroup.new
      g.title = (Etc.getpwnam(o).gecos || o)
      g.subtitle = o
      g.apps = UsrRouter.apps(owner: o)
      g
    end.select(&:has_apps?)
  end

  # Return an array of AppGroups with the apps sorted into groups that they
  # specify in the manifest with group title being the manifest. The default
  # AppGroup has the same title and subtitle as this AppGroup.
  def split
    groups = {}

    apps.each do |app|
      key = app.group
      key = nil if key == "" # group "" and nil together

      unless groups.has_key?(key)
        groups[key] = self.class.new.tap do |g|
          g.title = (key || title)
          g.subtitle = subtitle
        end
      end

      groups[key].apps << app
    end

    groups.values
  end
end
