module AppHelper
  # FIXME: show_errors is not used
  def manifest_markdown(text, show_errors: false)
    RenderManifestMarkdown.renderer.render(text).html_safe
  rescue
    text
  end

  def install_location(app)
    case app.type
    when :sys
      I18n.t('dashboard.all_apps_table_install_location_sys')
    when :dev
      I18n.t('dashboard.all_apps_table_install_location_dev')
    when :usr
      I18n.t('dashboard.all_apps_table_install_location_usr')
    else
      I18n.t('dashboard.unknown')
    end
  end
end
