class DashboardController < ApplicationController
  def index
    begin
       @motd = MotdFile.new.formatter
    rescue Exception => e
  	flash.now[:alert] = "MOTD was not parsed or rendered correctly: " + e.message   
    end
  end

  def logout
  end
end
