class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_logout_url

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
end
