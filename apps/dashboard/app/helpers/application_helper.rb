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
  # @return nil if url not set or the HTML string for the bootstrap nav link
  def nav_link(title, icon, url, target: "", role: nil)
    render partial: "layouts/nav/link", locals: { title: title, faicon: icon, url: url.to_s, target: target, role: role  } if url
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

  def fa_icon(icon, fa_style: "fas", id: "")
    content_tag(:i, "", id: id, class: [fa_style, "fa-#{icon}", "fa-fw", "app-icon"] , title: "FontAwesome icon specified: #{icon}", "aria-hidden": true)
  end

  def app_icon_tag(app)
    if app.icon_path.file?
      image_tag app_icon_path(app.name, app.type, app.owner), class: 'app-icon', title: app.icon_path
    else # default to font awesome icon
      if app.manifest.icon =~ /^(fa[bsrl]?):\/\/(.*)/
        icon = $2
        style = $1
        fa_icon(icon, fa_style: style)
      else
        fa_icon("cog")
      end
    end
  end

  def icon_tag(icon_uri)
    if %w(fa fas far fab fal).include?(icon_uri.scheme)
      fa_icon(icon_uri.host, fa_style: icon_uri.scheme)
    else
      image_tag icon_uri.to_s, class: "app-icon", title: icon_uri.to_s, "aria-hidden": true
    end
  end

end
