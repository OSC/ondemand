class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_logout_url, :set_nav_groups, :set_announcement

  def set_user
    @user = User.new
  end

  def set_logout_url
    if ENV['OOD_DASHBOARD_LOGOUT_URL'].present?
      @logout_url = (ENV['OOD_DASHBOARD_LOGOUT_URL'] % { login: ERB::Util.u(request.base_url) })
    else
      @logout_url = nil
    end
  end

  def set_nav_groups
    #TODO: for AweSim, what if we added the shared apps here?
    @nav_groups = OodAppGroup.select(titles: NavConfig.categories, groups: OodAppGroup.groups_for(apps: SysRouter.apps))
  end

  def set_announcement
    path = Pathname.new(ENV["OOD_ANNOUNCEMENT_PATH"] || "/etc/ood/config/announcement.md")
    @announcement = path.read if path.file?
  rescue => e
    logger.warn "Failed to read announcement file at: #{path} with error: #{e.message}"
  end
end
