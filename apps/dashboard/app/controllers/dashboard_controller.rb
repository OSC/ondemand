# The controller for dashboard (root) pages /dashboard
class DashboardController < ApplicationController
  include MotdConcern
  
  def index
    begin
      set_motd
    rescue StandardError => e
      flash.now[:alert] = t('dashboard.motd_erb_render_error', error_message: e.message)
    end
    set_my_quotas
  end

  def logout
  end
end
