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
end
