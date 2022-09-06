class NavBar

  def self.items(nav_config)
    nav_config.map do |nav_item|
      if nav_item.is_a?(String)
        item_from_token(nav_item)
      elsif nav_item.is_a?(Hash)
        if nav_item.fetch(:links, nil)
          extend_item(nav_menu(nav_item), 'layouts/nav/group')
        elsif nav_item.fetch(:url, nil)
          extend_item(nav_link(nav_item, nil, nil), 'layouts/nav/link')
        elsif nav_item.fetch(:apps, nil)
          matched_apps = nav_apps(nav_item, nil, nil)
          extend_item(matched_apps.first.links.first, 'layouts/nav/link') if matched_apps.first && matched_apps.first.links.first
        elsif nav_item.fetch(:template, nil)
          nav_template(nav_item)
        end
      end
    end.flatten.compact
  end

  private

  def self.nav_menu(hash_item)
    menu_title = hash_item.fetch(:title, '')
    menu_items = hash_item.fetch(:links, [])

    group_title = ''
    apps = menu_items.map do |item|
      group_title = item.fetch(:group, group_title)
      if item.fetch(:url, nil)
        nav_link(item, menu_title, group_title)
      elsif item.fetch(:apps, nil)
        nav_apps(item, menu_title, group_title)
      elsif item.fetch(:profile, nil)
        nav_profile(item, menu_title, group_title)
      end
    end.flatten.compact

    OodAppGroup.new(apps: apps, title: menu_title, sort: false)
  end

  def self.nav_link(item, category, subcategory)
    LinkDecorator.new(OodAppLink.new(item), category: category, subcategory: subcategory)
  end

  def self.nav_template(item)
    template = File.join("layouts/nav", item.fetch(:template))
    extend_item(item, template)
  end

  def self.nav_apps(item, category, subcategory)
    app_configs = Array.wrap(item.fetch(:apps, []))
    app_configs.map do |config_string|
      matched_apps = Router.pinned_apps_from_token(config_string, SysRouter.apps)
      matched_apps.map do |reg_app|
        AppDecorator.new(reg_app, category: category, subcategory: subcategory)
      end
    end.flatten
  end

  def self.nav_profile(item, category, subcategory)
    profile = item.fetch(:profile)
    profile_data = item.clone
    profile_data[:title] = profile unless item.fetch(:title, nil)
    profile_data[:url] = Rails.application.routes.url_helpers.settings_path('settings[profile]' => profile)
    profile_data[:data] = { method: 'post' }
    profile_data[:new_tab] = false
    LinkDecorator.new(OodAppLink.new(profile_data), category: category, subcategory: subcategory)
  end

  def self.item_from_token(token)
    matched_apps = Router.pinned_apps_from_token(token, SysRouter.apps)
    if matched_apps.size == 1
      extend_item(matched_apps.first.links.first, 'layouts/nav/link')
    elsif matched_apps.size > 1
      extend_item(OodAppGroup.groups_for(apps: matched_apps), 'layouts/nav/group')
    else
      group = OodAppGroup.groups_for(apps: SysRouter.apps, sort: false).select { |g| g.title.downcase == token.downcase }.first
      group.nil? ? nil : extend_item(group, 'layouts/nav/group')
    end
  end

  def self.extend_item(item, partial_path)
    extended = NavItemDecorator.new(item)
    extended.partial_path = partial_path
    extended
  end

  class NavItemDecorator < SimpleDelegator
    attr_accessor :partial_path
  end

  # redefine an OodApp's category & subcategory
  class AppDecorator < SimpleDelegator
    def initialize(link, category: nil, subcategory: nil)
      super(link)
      @inner_category = category
      @inner_subcategory = subcategory
    end

    def category
      inner_category
    end

    def subcategory
      inner_subcategory
    end

    private

    attr_reader :inner_category, :inner_subcategory
  end

  # make an OodAppLink look like an OodApp
  class LinkDecorator < SimpleDelegator
    attr_reader :category, :subcategory

    def initialize(link, category: nil, subcategory: nil)
      super(link)
      @category = category
      @subcategory = subcategory
    end

    def links
      [self]
    end

    def metadata
      {}
    end
  end

end