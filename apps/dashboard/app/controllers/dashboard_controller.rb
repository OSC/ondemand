class DashboardController < ApplicationController
  def index
    @motd = MotdFile.new.formatter
    set_my_quotas
  end

  def logout
  end

  def jobs
    render file: Rails.root.join("jobs.json"), content_type: 'application/json', layout: false
  end

  def perf
    render file: Rails.root.join("performance.json"), content_type: 'application/json', layout: false
  end

  def role
    render file: Rails.root.join("roles.json"), content_type: 'application/json', layout: false
  end
end
