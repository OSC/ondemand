# Creates navigation items based on user configuration.
#
class NavBar

  def self.items(nav_config)
    nav_config.map do |nav_item|
      if nav_item.is_a?(String)
        item_from_token(nav_item)
      elsif nav_item.is_a?(Hash)
        if nav_item[:links]
          extend_group(nav_menu(nav_item))
        elsif nav_item[:url]
          extend_link(nav_link(nav_item))
        elsif nav_item[:apps]
          matched_apps = nav_apps(nav_item, nav_item[:title], nil)
          if matched_apps.length == 1
            extend_link(matched_apps.first)
          elsif nav_item[:title]
            extend_group(OodAppGroup.new(apps: matched_apps, title: nav_item[:title], icon_uri: nav_item[:icon]), sort: true)
          end
        elsif nav_item[:profile]
          extend_link(nav_profile(nav_item))
        elsif !nav_item[:page].blank?
          extend_link(nav_page(nav_item))
        end
      end
    end.flatten.compact
  end

  def self.menu_items(menu_item)
    extend_group(nav_menu(menu_item || {}))
  end

  private

  def self.nav_menu(hash_item)
    menu_title = hash_item.fetch(:title, '')
    menu_icon = hash_item.fetch(:icon, nil)
    menu_items = hash_item.fetch(:links, [])

    group_title = ''
    apps = menu_items.map do |item|
      if item.is_a?(String)
        static_link = STATIC_LINKS.fetch(item.downcase.to_sym, nil)
        if static_link
          next static_link.categorize(category: menu_title, subcategory: group_title)
        end
        item = { apps: item }
      end

      if item[:url]
        nav_link(item, menu_title, group_title)
      elsif item[:apps]
        nav_apps(item, menu_title, group_title)
      elsif item[:profile]
        nav_profile(item, menu_title, group_title)
      elsif item[:page]
        nav_page(item, menu_title, group_title)
      else
        # Update subcategory if group title was provided
        group_title = item.fetch(:group, group_title)
        next nil
      end
    end.flatten.compact

    OodAppGroup.new(apps: apps, title: menu_title, icon_uri: menu_icon, sort: false)
  end

  def self.nav_link(item, category='', subcategory='')
    link_data = item.clone
    link_data[:icon_uri] = item.fetch(:icon, nil)
    link_data[:new_tab] = item.fetch(:new_tab, false)
    OodAppLink.new(link_data).categorize(category: category, subcategory: subcategory)
  end

  def self.nav_apps(item, category='', subcategory='')
    app_configs = Array.wrap(item.fetch(:apps, []))
    app_links = app_configs.map do |config_string|
      matched_apps = Router.pinned_apps_from_token(config_string, SysRouter.apps)
      extract_links(matched_apps, category: category, subcategory: subcategory)
    end.flatten
    override_app_link(app_links, item)
  end

  def self.nav_profile(item, category='', subcategory='')
    profile = item.fetch(:profile)
    profile_data = item.clone
    profile_data[:title] = item.fetch(:title, profile.titleize)
    profile_data[:url] = Rails.application.routes.url_helpers.settings_path('settings[profile]' => profile)
    profile_data[:icon_uri] = item.fetch(:icon, nil)
    profile_data[:data] = { method: 'post' }
    profile_data[:new_tab] = item.fetch(:new_tab, false)
    OodAppLink.new(profile_data).categorize(category: category, subcategory: subcategory)
  end

  def self.nav_page(item, category='', subcategory='')
    page_code = item.fetch(:page)
    page_data = item.clone
    page_data[:title] = item.fetch(:title, page_code.titleize)
    page_data[:url] = Rails.application.routes.url_helpers.custom_pages_path(page_code)
    page_data[:icon_uri] = item.fetch(:icon, nil)
    page_data[:new_tab] = item.fetch(:new_tab, false)
    OodAppLink.new(page_data).categorize(category: category, subcategory: subcategory)
  end

  def self.override_app_link(app_links, item)
    if app_links.length == 1
      app_link = app_links.first
      data = app_link.to_h
      data[:title] = item.fetch(:title, app_link.title)
      data[:icon_uri] = item.fetch(:icon, app_link.icon_uri)
      [OodAppLink.new(data).categorize(category: app_link.category, subcategory: app_link.subcategory, show_in_menu: app_link.show_in_menu?)]
    else
      app_links
    end
  end

  def self.item_from_token(token)
    static_template = STATIC_TEMPLATES.fetch(token.downcase.to_sym, nil)
    if static_template
      return NavItemDecorator.new(OodAppGroup.new, static_template)
    end

    static_link = STATIC_LINKS.fetch(token.downcase.to_sym, nil)
    if static_link
      return extend_link(static_link.categorize)
    end

    matched_apps = Router.pinned_apps_from_token(token, SysRouter.apps)
    if matched_apps.size == 1
      app = AppRecategorizer.new(matched_apps.first, category: '', subcategory: '')
      extend_link(app.links.first.categorize(show_in_menu: app.batch_connect_app?)) if app.links.first
    else
      group = OodAppGroup.groups_for(apps: SysRouter.apps).select { |g| g.title.downcase == token.downcase }.first
      return nil if group.nil?
      group.apps = extract_links(group.apps)
      extend_group(group, sort: true)
    end
  end

  def self.extract_links(apps, category: nil, subcategory: nil)
    apps.map do |app|
      app.links.map do |link|
        link.categorize(category: category || app.category, subcategory: subcategory || app.subcategory, show_in_menu: app.batch_connect_app?)
      end
    end.flatten
  end

  def self.extend_group(group, sort: false)
    group.sort = sort
    NavItemDecorator.new(group, 'layouts/nav/group')
  end

  def self.extend_link(link)
    NavItemDecorator.new(link, 'layouts/nav/link')
  end

  class NavItemDecorator < SimpleDelegator
    attr_reader :partial_path, :links

    def initialize(nav_item, partial_path)
      super(nav_item)
      @partial_path = partial_path
      @links = nav_item.links.flatten.compact
    end
  end

  class MultikeyHash < Hash
    def []=(keys, value)
      keys.each do |key|
        super(key.to_sym, value)
      end
    end
  end

  STATIC_TEMPLATES = MultikeyHash.new.tap do |hash|
    hash[['all_apps', 'all apps']] = 'layouts/nav/all_apps'
    hash[['featured_apps', 'apps', 'pinned_apps', 'pinned apps', 'featured apps']] = 'layouts/nav/featured_apps'
    hash[['sessions', 'my_interactive_sessions', 'my interactive sessions']] = 'layouts/nav/sessions'
    hash[['develop']] = 'layouts/nav/develop_dropdown'
    hash[['help']] = 'layouts/nav/help_dropdown'
    hash[['log_out', 'logout', 'log out']] = 'layouts/nav/log_out'
    hash[['user']] = 'layouts/nav/user'
  end.freeze

  url_helpers =  Rails.application.routes.url_helpers
  STATIC_LINKS = MultikeyHash.new.tap do |hash|
    hash[['all_apps', 'all apps']] = OodAppLink.new(title: I18n.t('dashboard.nav_all_apps'), url: url_helpers.apps_index_path, icon_uri: URI('fas://th'), new_tab: false)
    hash[['sessions', 'my_interactive_sessions', 'my interactive sessions']] = OodAppLink.new(title: I18n.t('dashboard.nav_sessions'), url: url_helpers.batch_connect_sessions_path, icon_uri: URI('fas://window-restore'), new_tab: false)
    hash[['support_ticket', 'support ticket', 'support']] = OodAppLink.new(title: I18n.t('dashboard.nav_help_support_ticket'), url: url_helpers.support_path, icon_uri: URI('fas://medkit'), new_tab: false) if url_helpers.respond_to?(:support_path)
    hash[['docs']] = OodAppLink.new(title: I18n.t('dashboard.nav_develop_docs'), url: Configuration.developer_docs_url, icon_uri: URI('fas://book'), new_tab: true)
    hash[['products_dev', 'products dev']] = OodAppLink.new(title: I18n.t('dashboard.nav_develop_my_sandbox_apps_dev'), url: url_helpers.products_path(type: 'dev'), icon_uri: URI('fas://cog'), new_tab: false)
    hash[['products_usr', 'products usr']] = OodAppLink.new(title: I18n.t('dashboard.nav_develop_my_sandbox_apps_prod'), url: url_helpers.products_path(type: 'usr'), icon_uri: URI('fas://share-alt'), new_tab: false)
    hash[['log_out', 'logout', 'log out']] = OodAppLink.new(title: I18n.t('dashboard.nav_logout'), url: '/logout', icon_uri: URI('fas://sign-out-alt'), new_tab: false)
    hash[['restart']] = OodAppLink.new(title: I18n.t('dashboard.nav_restart_server'), url: "/nginx/stop?redir=#{url_helpers.root_path}", icon_uri: URI('fas://sync'), new_tab: false)
  end.freeze

end