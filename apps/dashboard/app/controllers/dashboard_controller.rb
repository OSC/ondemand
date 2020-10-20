class DashboardController < ApplicationController
  def index
    begin
       @motd = MotdFile.new.formatter
    rescue Exception => e
       render "errors/motd_erb_error", locals: { e: e }
    end
  end

  def logout
  end
end
