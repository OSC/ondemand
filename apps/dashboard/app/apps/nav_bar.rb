# Creates navigation items based on user configuration.
#
class NavBar

  STATIC_LINKS = {
    all_apps: "layouts/nav/all_apps",
    featured_apps: "layouts/nav/featured_apps",
    sessions: "layouts/nav/sessions",
    log_out: "layouts/nav/log_out",
    user: "layouts/nav/user",
  }

  def self.items(nav_config)
    nav_config.map do |nav_item|
      if nav_item.is_a?(String)
        item_from_token(nav_item)
      elsif nav_item.is_a?(Hash)
        if nav_item.fetch(:links, nil)
          extend_group(nav_menu(nav_item))
        elsif nav_item.fetch(:url, nil)
          extend_link(nav_link(nav_item, nil, nil))
        elsif nav_item.fetch(:apps, nil)
          matched_apps = nav_apps(nav_item, nil, nil)
          extend_link(matched_apps.first.links.first) if matched_apps.first && matched_apps.first.links.first
        elsif nav_item.fetch(:profile, nil)
          extend_link(nav_profile(nav_item, nil, nil))
        elsif nav_item.fetch(:page, nil)
          extend_link(nav_page(nav_item, nil, nil))
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
      if item.is_a?(String)
        item = { apps: item }
      end

      if item.fetch(:url, nil)
        nav_link(item, menu_title, group_title)
      elsif item.fetch(:apps, nil)
        nav_apps(item, menu_title, group_title)
      elsif item.fetch(:profile, nil)
        nav_profile(item, menu_title, group_title)
      elsif item.fetch(:page, nil)
        nav_page(item, menu_title, group_title)
      else
        # Update subcategory if title was provided
        group_title = item.fetch(:group, group_title)
        next nil
      end
    end.flatten.compact

    OodAppGroup.new(apps: apps, title: menu_title, sort: false)
  end

  def self.nav_link(item, category, subcategory)
    OodAppLink.new(item).categorize(category: category, subcategory: subcategory)
  end

  def self.nav_apps(item, category, subcategory)
    app_configs = Array.wrap(item.fetch(:apps, []))
    app_configs.map do |config_string|
      matched_apps = Router.pinned_apps_from_token(config_string, SysRouter.apps)
      matched_apps.map do |reg_app|
        AppRecategorizer.new(reg_app, category: category, subcategory: subcategory)
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
    OodAppLink.new(profile_data).categorize(category: category, subcategory: subcategory)
  end

  def self.nav_page(item, category, subcategory)
    page_code = item.fetch(:page)
    page_data = item.clone
    page_data[:title] = page_data.fetch(:title, page_code.titleize)
    page_data[:url] = Rails.application.routes.url_helpers.custom_pages_path(page_code)
    page_data[:new_tab] = page_data.fetch(:new_tab, false)
    OodAppLink.new(page_data).categorize(category: category, subcategory: subcategory)
  end

  def self.item_from_token(token)
    static_link_template = STATIC_LINKS.fetch(token.to_sym, nil)
    if static_link_template
      return NavItemDecorator.new({}, static_link_template)
    end

    matched_apps = Router.pinned_apps_from_token(token, SysRouter.apps)
    if matched_apps.size == 1
      extend_link(matched_apps.first.links.first) if matched_apps.first.links.first
    elsif matched_apps.size > 1
      extend_group(OodAppGroup.groups_for(apps: matched_apps).first)
    else
      group = OodAppGroup.groups_for(apps: SysRouter.apps).select { |g| g.title.downcase == token.downcase }.first
      group.nil? ? nil : extend_group(group)
    end
  end

  def self.extend_group(item)
    NavItemDecorator.new(item, 'layouts/nav/group')
  end

  def self.extend_link(item)
    NavItemDecorator.new(item, 'layouts/nav/link')
  end

  class NavItemDecorator < SimpleDelegator
    attr_reader :partial_path

    def initialize(nav_item, partial_path)
      super(nav_item)
      @partial_path = partial_path
    end
  end
end