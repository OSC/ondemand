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
    flash.now[:alert] = "OnDemand requires a newer version of the browser you are using. Current browser requirements include IE Edge, Firefox 19+, Chrome 34+, Safari 8+." unless view_context.browser.modern?
    flash.now[:alert] = "OnDemand is not yet optimized for mobile use." if view_context.browser.device.mobile?
  end

end
