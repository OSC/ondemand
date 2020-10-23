class DashboardController < ApplicationController
  def index
    begin
      @motd = MotdFile.new.formatter
    rescue StandardError => e
  	  flash.now[:alert] = t('dashboard.motd_erb_render_error', error_message: e.message)
    end
  end

  def logout
  end
end
