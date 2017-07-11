class DashboardController < ApplicationController
  def index
    @motd = MotdFile.new.formatter
  end

  def logout
  end
end
