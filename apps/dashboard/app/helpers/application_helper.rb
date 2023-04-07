# frozen_string_literal: true

# Helper for all pages.
module ApplicationHelper
  def clusters
    OodCore::Clusters.new(OodAppkit.clusters.select(&:allow?).reject { |c| c.metadata.hidden })
  end

  def login_clusters
    OodCore::Clusters.new(clusters.select(&:login_allow?))
  end

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end

  # Render a bootstrap nav link if the url is specified.
  # Do nothing if the url is nil.
  #
  # @param title [String] link text
  # @param icon [String] favicon icon name (i.e. "refresh" "for "fa "fa-refresh")
  # @param url [#to_s, nil] url to access
  # @param role [String] app role i.e. "vdi", "shell", etc.
  # @param data [Hash] data parameter for the link_to helper.
  # @return nil if url not set or the HTML string for the bootstrap nav link
  def nav_link(title, icon, url, new_tab: false, role: nil, data: nil)
    if url
      icon_uri = URI("fa://#{icon}")
      render partial: 'layouts/nav/link',
             locals:  { title: title, class: 'dropdown-item', icon_uri: icon_uri, url: url.to_s, new_tab: new_tab, role: role, data: data }
    end
  end

  def support_url
    ENV['OOD_DASHBOARD_SUPPORT_URL']
  end

  def docs_url
    ENV['OOD_DASHBOARD_DOCS_URL']
  end

  def configure_2fa_url
    ENV['OOD_DASHBOARD_2FA_URL']
  end

  def passwd_url
    ENV['OOD_DASHBOARD_PASSWD_URL']
  end

  def help_custom_url
    ENV['OOD_DASHBOARD_HELP_CUSTOM_URL']
  end

  def fa_icon(icon, fa_style: 'fas', id: '', classes: 'app-icon', title: "FontAwesome icon specified: #{icon}")
    content_tag(:i, '', id: id, class: [fa_style, "fa-#{icon}", 'fa-fw'].concat(Array(classes)),
                title: title, "aria-hidden": true)
  end

  def app_icon_tag(app)
    if app.image_icon?
      image_tag app.icon_uri, class: 'app-icon', title: app.icon_path
    elsif app.manifest.icon =~ %r{^(fa[bsrl]?)://(.*)} # default to font awesome icon
      icon = Regexp.last_match(2)
      style = Regexp.last_match(1)
      fa_icon(icon, fa_style: style)
    else
      fa_icon('cog')
    end
  end

  def icon_tag(icon_uri, classes: ['app-icon'])
    if ['fa', 'fas', 'far', 'fab', 'fal'].include?(icon_uri.scheme)
      fa_icon(icon_uri.host, fa_style: icon_uri.scheme, classes: classes)
    elsif icon_uri.to_s.starts_with?(@user_configuration.public_url.to_s)
      content_tag(:img, '', src: icon_uri.to_s, class: classes, title: icon_uri.to_s, "aria-hidden": true)
    else
      image_tag icon_uri.to_s, class: classes, title: icon_uri.to_s, "aria-hidden": true
    end
  end

  # Creates the list of links to add to the help menu
  def help_links
    help_items = ["restart"] + @user_configuration.profile_links + @user_configuration.help_menu
    NavBar.menu_items({ links: help_items }) unless help_items.empty?
  end

  def custom_css_paths
    @user_configuration.custom_css_files.map do |css_file|
      css_file.to_s.empty? ? nil : File.join(@user_configuration.public_url, css_file)
    end.compact
  end
end
