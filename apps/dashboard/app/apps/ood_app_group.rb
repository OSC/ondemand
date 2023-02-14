# OodAppGroup groups OodApps mostly through class methods. The object
# OodAppGroup is itself a group of OodApps.
class OodAppGroup
  attr_accessor :apps, :title, :icon_uri, :sort

  def initialize(title: "", icon_uri: nil, apps: [], nav_limit: nil, sort: true)
    @apps = apps
    @title = title
    @icon_uri = URI(icon_uri.to_s) if icon_uri
    @nav_limit = nav_limit
    @sort = sort
  end

  def has_apps?
    apps.count > 0
  end

  def has_batch_connect_apps?
    return @has_batch_connect_apps unless @has_batch_connect_apps.nil?
    @has_batch_connect_apps = apps.any?(&:batch_connect_app?)
  end

  def nav_limit_caption
    @nav_limit_caption ||= begin
      if nav_limit < apps.size
        I18n.t('dashboard.nav_limit_caption', subset_count: nav_limit, total_count: apps.size)
      else
        ''
      end
    end
  end

  def title_with_nav_limit_caption
    if nav_limit_caption.present?
      "#{title} (#{nav_limit_caption})"
    else
      title
    end
  end

  def nav_limit
    @nav_limit || apps.size
  end

  def links
    apps.map(&:links).flatten
  end

  def to_h
    {
      :group => self,
      :apps => apps,
      :title => title,
      :icon_uri => icon_uri,
      :nav_limit => nav_limit,
      :sort => sort
    }
  end

  # Given an array of apps, group those apps by app category (or the attribute)
  # specified by 'group_by', potentially sorting both groups and apps arrays by title if sort is true.
  def self.groups_for(apps: [], group_by: :category, nav_limit: nil, sort: true)
    groups = apps.group_by { |app|
      app.respond_to?(group_by) ? app.send(group_by) : app.metadata[group_by]
    }.map { |k,v|
      OodAppGroup.new(title: k, apps: sort ? v.sort_by { |a| a.title } : v, nav_limit: nav_limit)
    }
    sort ? groups.sort_by { |g| [ g.title.to_s.empty? ? 1 : 0, g.title ] } : groups # make sure that the ungroupable app is always last
  end

  # Select a subset of groups by the specified array of titles
  # maintaining the order specified by the titles array.
  #
  # This way we can get a list of deployed sys apps, then group them by category
  # then select only the categories we want to display in the menu.
  def self.select(titles:[], groups:[])
    # only one group per title; this just makes it easy to get the group
    # Hash[ [:title1,:group1], [:title2,:group2]] => {title1: :group1, title2: :group2 }
    h = Hash[groups.map {|g| [g.title, g]}]
    titles.map { |t| h.has_key?(t) ? h[t] : nil }.compact
  end
  
  # Append groups not in the specified array in alphabetical order at the end of
  # subset of groups in the titles array maintaining the order specified by the titles array.
  #
  # This way we can get a list of deployed sys apps, then group them by category,
  # then display categories in titles array in specific order,
  # then display other categories in alphabetical order
  def self.order(titles:[], groups:[])
      h = Hash[groups.map {|g| [g.title, g]}]
      (titles + h.keys.sort).uniq.map { |t| h.has_key?(t) ? h[t] : nil }.compact
  end
end
