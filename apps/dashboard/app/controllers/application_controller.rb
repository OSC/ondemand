# The parent controller for all other controllers.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_user, :set_user_configuration, :set_pinned_apps, :set_nav_groups, :set_announcements
  before_action :set_my_balances, only: [:index, :new, :featured]
  before_action :set_featured_group, :set_custom_navigation
  before_action :check_required_announcements

  def check_required_announcements
    return if instance_of?(SettingsController)

    render inline: '', layout: :default if @announcements.select(&:required?).reject(&:completed?).any?
  end

  def set_user
    @user = CurrentUser
  end

  def set_user_configuration
    @user_configuration ||= UserConfiguration.new(request_hostname: request.hostname)
  end

  def set_custom_navigation
    @nav_bar = NavBar.items(@user_configuration.nav_bar)
    @help_bar = NavBar.items(@user_configuration.help_bar)
  end

  def set_nav_groups
    #TODO: for AweSim, what if we added the shared apps here?
    @nav_groups = filter_groups(sys_app_groups)
  end

  def set_featured_group
    apps = AppRecategorizer.recategorize(@pinned_apps, I18n.t("dashboard.pinned_apps_category"), I18n.t('dashboard.pinned_apps_title'))
    group = OodAppGroup.groups_for(apps: apps, nav_limit: @user_configuration.pinned_apps_menu_length)

    @featured_group = filter_groups(group).first # 1 single group called 'Apps'
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

  def set_pinned_apps
    @pinned_apps ||= Router.pinned_apps(@user_configuration.pinned_apps, nav_all_apps)
  end

  def set_announcements
    @announcements ||= Announcements.all(@user_configuration.announcement_path)
  rescue => e
    logger.warn "Error parsing announcements: #{e.message}"
    @announcements ||= []
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
    if @user_configuration.filter_nav_categories?
      OodAppGroup.select(titles: @user_configuration.nav_categories, groups: groups)
    else
      OodAppGroup.order(titles: @user_configuration.nav_categories, groups: groups)
    end
  end
end
