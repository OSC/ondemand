module ApplicationHelper
  def clusters
    OodAppkit::Clusters.new(OodAppkit.clusters.select(&:valid?).select(&:hpc_cluster?))
  end

  def login_clusters
    OodAppkit::Clusters.new(clusters.select(&:login_server?))
  end

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end


  def support_url
    ENV['OOD_DASHBOARD_SUPPORT_URL'] || "#"
  end

  def docs_url
    ENV['OOD_DASHBOARD_DOCS_URL'] || "#"
  end

  def passwd_url
    ENV['OOD_DASHBOARD_PASSWD_URL'] || "#"
  end

  # FIXME: temporary solution
  def render_nav
    if ENV['OOD_APP_SHARING'].present?
      render partial: "layouts/nav/app_sharing_nav"
    elsif ENV['OOD_DASHBOARD_SHOW_ALL_APPS'].present?
      render partial: "layouts/nav/nav"
    else
      render partial: "layouts/nav/simple_nav"
    end
  end

  # TODO: if we keep the separate classes for icons
  # def app_icon_tag(app)
  #   if app.icon_path.file?
  #     ImageIcon.new(app.icon_path, app_icon_path(app.name, app.type, app.owner)).html
  #   else
  #     FontAwesomeIcon.new(app.manifest.icon).html
  #   end
  # end

  # TODO: if we get rid of the separate classes for icons
  def app_icon_tag(app)
    if app.icon_path.file?
      image_tag app_icon_path(app.name, app.type, app.owner), class: 'app-icon', title: app.icon_path
    elsif(app.manifest.icon =~ /fa:\/\/(.*)/)
      fa_tag(name: $1, css_class: "app-icon", title: app.icon_path)

      # later we would add multiple formats and templates below
    else
      # default - font awesome gear
      fa_tag(name: "gear", css_class: "app-icon", title: app.icon_path)
    end
  end

  def fa_tag(name:, css_class: [], title: "")
    content_tag(:i, "", class: ["fa", "fa-#{name}"].concat(Array(css_class)) , title: title)
  end
end
