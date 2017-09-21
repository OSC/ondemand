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
  def nav_link(title, icon, url, target: "_self", role: nil)
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

  def app_icon_tag(app)
    if app.icon_path.file?
      image_tag app_icon_path(app.name, app.type, app.owner), class: 'app-icon', title: app.icon_path
    else # default to font awesome icon
      icon = (app.manifest.icon =~ /fa:\/\/(.*)/) ? $1 : "gear"
      content_tag(:i, "", class: ["fa", "fa-#{icon}", "fa-fw", "app-icon"] , title: "FontAwesome icon specified: #{icon}")
    end
  end
end
