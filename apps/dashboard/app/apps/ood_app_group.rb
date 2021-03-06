class OodAppGroup
  attr_accessor :apps
  
  PINNED_APPS_TITLE = I18n.t('dashboard.pinned_apps_title')
  
  def initialize(title: "", apps: [])
    @apps = apps
    @_title = title
  end

  def has_apps?
    apps.count > 0
  end

  def has_batch_connect_apps?
    return @has_batch_connect_apps unless @has_batch_connect_apps.nil?
    @has_batch_connect_apps = apps.any?(&:batch_connect_app?)
  end

  def title
    @title ||= begin
      if @_title == PINNED_APPS_TITLE
        if apps.size > nav_limit
          "#{PINNED_APPS_TITLE} (showing #{nav_limit} of #{apps.size})"
        else
          PINNED_APPS_TITLE
        end
      else
        @_title
      end
    end
  end

  def nav_limit
    @nav_limit ||= begin
      if @_title == PINNED_APPS_TITLE
        ::Configuration.pinned_apps_menu_length
      else
        apps.size
      end
    end
  end

  # given an array of apps, group those apps by app category (or the attribute)
  # specified by 'group_by', sorting both groups and apps arrays by title
  def self.groups_for(apps: [], group_by: :category)
    apps.group_by { |app|
      app.send(group_by)
    }.map { |k,v|
      OodAppGroup.new(title: k, apps: v.sort_by { |a| a.title })
    }.sort_by { |g| g.title }
  end

  # select a subset of groups by the specified array of titles
  # maintaining the order specified by the titles array
  #
  # This way we can get a list of deployed sys apps, then group them by category
  # then select only the categories we want to display in the menu
  def self.select(titles:[], groups:[])
    # only one group per title; this just makes it easy to get the group
    # Hash[ [:title1,:group1], [:title2,:group2]] => {title1: :group1, title2: :group2 }
    h = Hash[groups.map {|g| [g.title, g]}]
    titles.map { |t| h.has_key?(t) ? h[t] : nil }.compact
  end
  
  # Append groups not in the specified array in alphabetical order at the end of
  # subset of groups in the titles array maintaining the order specified by the titles array
  #
  # This way we can get a list of deployed sys apps, then group them by category,
  # then display categories in titles array in specific order,
  # then display other categories in alphabetical order
  def self.order(titles:[], groups:[])
      h = Hash[groups.map {|g| [g.title, g]}]
      titles.concat(h.keys.sort).uniq.map { |t| h.has_key?(t) ? h[t] : nil }.compact 
  end
end
