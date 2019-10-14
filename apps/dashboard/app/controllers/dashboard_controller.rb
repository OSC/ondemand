class DashboardController < ApplicationController
  def index
    @motd = MotdFile.new.formatter
    set_my_quotas
  end

  def logout
  end
end
