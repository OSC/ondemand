# OodAppGroup groups OodApps mostly through static methods. The object
# OodAppGroup is itself a group.
class OodAppGroup
  attr_accessor :apps, :title, :sort

  def initialize(title: "", apps: [], nav_limit: nil, sort: true)
    @apps = apps
    @title = title
    @nav_limit = nav_limit
    @sort = sort
  end

  # Determines whether this app group has any apps.
  #
  # @return [Boolean] Wether this app group has any apps.
  def has_apps?
    apps.count > 0
  end

  # Determines whether this app group has any batch connect apps.
  #
  # @return [Boolean] Wether this app group has any batch connect apps.
  def has_batch_connect_apps?
    return @has_batch_connect_apps unless @has_batch_connect_apps.nil?
    @has_batch_connect_apps = apps.any?(&:batch_connect_app?)
  end

  # Get the caption for this group's limit for the navigation bar as a string.
  #
  # @return [String] The caption as a string.
  def nav_limit_caption
    @nav_limit_caption ||= begin
      if nav_limit < apps.size
        I18n.t('dashboard.nav_limit_caption', subset_count: nav_limit, total_count: apps.size)
      else
        ''
      end
    end
  end

  # Get the title of this app grop with the navigation limit caption.
  #
  # @return [String] The title as a string.
  def title_with_nav_limit_caption
    if nav_limit_caption.present?
      "#{title} (#{nav_limit_caption})"
    else
      title
    end
  end

  # Get the limit of applications to be shown in the navigation menu.
  #
  # @return [Integer] The navigation limit.
  def nav_limit
    @nav_limit || apps.size
  end

  # Get this object as a hash.
  #
  # @return [Hash] This object as a hash.
  def to_h
    {
      :group => self,
      :apps => apps,
      :title => title,
      :nav_limit => nav_limit,
      :sort => sort
    }
  end

  # Given an array of apps, group those apps by app category (or the attribute)
  # specified by 'group_by', sorting both groups and apps arrays by title.
  #
  # @param [Array] apps: An array of OodApps to group.
  # @param [Symbol] group_by: The OodApp attribute to group by.
  # @param [Integer] nav_limit: Limit the number of apps in the resulting group by this number.
  # @param [Boolean] sort: Wether or not the groups should be sorted.
  #
  # @return [Array<OodAppGroup>] The OodAppGroups you've grouped the apps into.
  def self.groups_for(apps: [], group_by: :category, nav_limit: nil, sort: true)
    groups = apps.group_by { |app|
      app.respond_to?(group_by) ? app.send(group_by) : app.metadata[group_by]
    }.map { |k,v|
      OodAppGroup.new(title: k, apps: sort ? v.sort_by { |a| a.title } : v, nav_limit: nav_limit)
    }
    sort ? groups.sort_by { |g| [ g.title.nil? ? 1 : 0, g.title ] } : groups # make sure that the ungroupable app is always last
  end

  # Select a subset of groups by the specified array of titles
  # maintaining the order specified by the titles array.
  #
  # This way we can get a list of deployed sys apps, then group them by category
  # then select only the categories we want to display in the menu.
  #
  # @param [Array<String>] titles: The titles from which to select.
  # @param [Array<OodAppGroup>] groups: The groups from which to select.
  #
  # @return [Hash] The resulting hash of OodAppGroups keyed by titles.
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
  # then display other categories in alphabetical order.
  #
  # @param [Array<String>] titles: The titles from which to order.
  # @param [Array<OodAppGroup>] groups: The groups from which to order.
  #
  # @return [Hash] The resulting hash of OodAppGroups keyed by titles.
  def self.order(titles:[], groups:[])
      h = Hash[groups.map {|g| [g.title, g]}]
      (titles + h.keys.sort).uniq.map { |t| h.has_key?(t) ? h[t] : nil }.compact
  end
end
