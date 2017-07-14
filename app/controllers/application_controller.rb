class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_nav_groups, :set_announcement, :set_browser_alert

  def set_user
    @user = User.new
  end

  def set_nav_groups
    #TODO: for AweSim, what if we added the shared apps here?
    @nav_groups = OodAppGroup.select(titles: NavConfig.categories, groups: sys_app_groups)
  end

  def sys_app_groups
    @sys_app_groups ||= OodAppGroup.groups_for(apps: SysRouter.apps)
  end

  def set_announcement
    path = Pathname.new(ENV["OOD_ANNOUNCEMENT_PATH"] || "/etc/ood/config/announcement.md")
    @announcement = path.read if path.file?
  rescue => e
    logger.warn "Failed to read announcement file at: #{path} with error: #{e.message}"
  end

  def set_browser_alert
    flash.now[:browser_alert] = "OnDemand requires a newer version of the browser you are using. Current browser requirements include IE Edge, Firefox 19+, Chrome 34+, Safari 8+.".html_safe unless view_context.browser.modern?
    flash.now[:browser_alert] = "OnDemand is not yet optimized for mobile use.".html_safe if view_context.browser.device.mobile?
    safari_warning = "As currently configured, the Cluster and Interactive Apps of Open OnDemand do not work with Safari. This is due to a bug in Safari with using websockets through servers protected using \"Basic\" auth. Open OnDemand can be installed with another authentication mechanism such as Shibboleth or OpenID Connect. If \"Basic\" auth is required, Mac users can connect with other browsers like Chrome or Firefox. Please contact this site’s technical support and report this message.".html_safe
    flash.now[:browser_alert] = safari_warning if !ENV["DISABLE_SAFARI_BASIC_AUTH_WARNING"] && browser.safari?
  end

end
