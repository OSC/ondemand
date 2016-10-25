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

  def app_icon_tag(app)
    if app.icon_path.file?
      image_tag app_icon_path(app.name, app.type, app.owner), size: '100x100', title: app.icon_path
    else
      content_tag(:i, "", class: ["fa", "fa-gear"], style: 'font-size: 100px;', title: app.icon_path)
    end
  end
end
