class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_user, :set_pinned_apps, :set_nav_groups, :set_announcements
  before_action :set_my_balances, only: [:index, :new, :featured]
  before_action :set_featured_group

  def set_user
    @user = CurrentUser
  end

  def set_nav_groups
    #TODO: for AweSim, what if we added the shared apps here?
    @nav_groups = filter_groups(sys_app_groups)
  end

  def set_featured_group
    @featured_group = filter_groups(pinned_app_group).first # 1 single group called 'Apps'
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

  def nav_all_apps
    @nav_all_apps ||= nav_sys_apps + nav_usr_apps + nav_dev_apps
  end

  def nav_sys_apps
    sys_apps.select(&:should_appear_in_nav?)
  end

  def nav_dev_apps
    dev_apps.select(&:should_appear_in_nav?)
  end

  def nav_usr_apps
    usr_apps.select(&:should_appear_in_nav?)
  end

  def sys_app_groups
    OodAppGroup.groups_for(apps: nav_sys_apps)
  end

  def pinned_app_group
    OodAppGroup.groups_for(apps: @pinned_apps, nav_limit: ::Configuration.pinned_apps_menu_length)
  end

  def set_pinned_apps
    @pinned_apps ||= Router.pinned_apps(::Configuration.pinned_apps, nav_all_apps)
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
    ::Configuration.quota_paths.each { |path| @my_quotas += Quota.find(path, OodSupport::User.new.name) }
    @my_quotas
  end

  # Set a list of my balances which can be used to display warnings if there is
  # an insufficient balance
  def set_my_balances
    @my_balances = []
    ::Configuration.balance_paths.each { |path| @my_balances += Balance.find(path, OodSupport::User.new.name) }
    @my_balances
  end

  private

  def filter_groups(groups)
    if NavConfig.categories_whitelist?
      OodAppGroup.select(titles: NavConfig.categories, groups: groups)
    else
      OodAppGroup.order(titles: NavConfig.categories, groups: groups)
    end
  end
end
