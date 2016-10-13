class OodAppGroup
  attr_accessor :apps, :title, :subtitle

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

  # Return an array of AppGroups with the apps sorted into groups that they
  # specify in the manifest with group title being the manifest. The default
  # AppGroup has the same title and subtitle as this AppGroup.
  def split
    groups = {}

    apps.each do |app|
      key = app.category
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
