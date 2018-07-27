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

  def sys_apps
    @sys_apps ||= SysRouter.apps
  end

  def dev_apps
    @dev_apps ||= ::Configuration.app_development_enabled? ? DevRouter.apps : []
  end

  def usr_apps
    @usr_apps ||= ::Configuration.app_sharing_enabled? ? UsrRouter.all_apps(owners: UsrRouter.owners) : []
  end

  def nav_sys_apps
    sys_apps.select(&:manifest?).reject(&:invalid_batch_connect_app?)
  end

  def nav_dev_apps
    dev_apps.select(&:manifest?).reject(&:invalid_batch_connect_app?)
  end

  def nav_usr_apps
    usr_apps.select(&:manifest?).reject(&:invalid_batch_connect_app?)
  end

  def sys_app_groups
    OodAppGroup.groups_for(apps: nav_sys_apps)
  end

  def set_announcements
    @announcements = Announcements.all(::Configuration.announcement_path)
  rescue => e
    logger.warn "Error parsing announcements: #{e.message}"
    @announcements = []
  end

  # Set a list of my quotas which can be used to display warnings if there is
  # an insufficient disk resource
  def set_my_quotas
    @my_quotas = []
    ::Configuration.quota_paths.each { |path| @my_quotas += Quota.find(path, OodSupport::User.new) }
    @my_quotas
  end
end
