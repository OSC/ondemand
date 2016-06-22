class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_logout_url

  def set_user
    @user = User.new
  end

  def set_logout_url
    @logout_url = "/oidc?logout="

    #FIXME: HACK - delete when no longer using websvcs08
    @logout_url = "/oidc/?logout=" if request.base_url =~ /websvcs08\.osc\.edu/
    #end HACK

    @logout_url = @logout_url + ERB::Util.u(request.base_url)
  end
end
