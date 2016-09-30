class OodAppGroup
  attr_accessor :apps, :title, :subtitle

  def initialize
    @apps = []
  end

  def has_apps?
    apps.count > 0
  end

  # TODO: write lots of tests so we can refactor this well...
  def self.usr_groups(owners)
    # TODO: this gets much more complex when we have apps specifying
    # which groups they should be filtered under
    Array(owners).map do |o|
      g = OodAppGroup.new
      g.title = o
      g.subtitle = o
      g.apps = UsrRouter.apps(owner: o)
      g
    end.select(&:has_apps?)
  end
end
