class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_nav_groups, :set_announcements

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

  def set_announcements
    @announcements = Announcements.all(Configuration.announcement_path)
  rescue => e
    logger.warn "Error parsing announcements: #{e.message}"
    @announcements = []
  end
end
