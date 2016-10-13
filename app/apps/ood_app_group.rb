class OodAppGroup
  attr_accessor :apps, :title

  def initialize(title: "", apps: [])
    @apps = apps
    @title = title
  end

  def has_apps?
    apps.count > 0
  end

  def self.groups_for(apps: [])
    apps.group_by { |app|
      app.category
    }.map { |k,v|
      OodAppGroup.new(title: k, apps: v)
    }
  end
end
