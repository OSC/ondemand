module ApplicationHelper
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
    if ENV['OOD_DASHBOARD_SHOW_ALL_APPS']
      render partial: "layouts/nav/nav"
    else
      render partial: "layouts/nav/simple_nav"
    end
  end
end
