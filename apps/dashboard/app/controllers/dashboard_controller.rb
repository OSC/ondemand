# The controller for dashboard (root) pages /dashboard
class DashboardController < ApplicationController
  def index

    @recently_used_apps = recently_used_apps

    begin
      @motd = MotdFile.new.formatter
    rescue StandardError => e
      flash.now[:alert] = t('dashboard.motd_erb_render_error', error_message: e.message)
    end
    set_my_quotas
  end

  def logout
  end

  def recently_used_apps
    cache_files = Dir.glob("#{BatchConnect::Session.cache_root}/*.json").sort_by do |file|
      File.mtime(file)
    end.reverse.slice(0, 4)

    base_apps = SysRouter.apps.select do |app|
      app.batch_connect_app? && cache_files.include?("#{BatchConnect::Session.cache_root}/#{app.batch_connect.cache_file}")
    end.map do |app|
      cache_data = JSON.parse(File.read("#{BatchConnect::Session.cache_root}/#{app.batch_connect.cache_file}")).to_h
      AppPreseter.new(app, cache_data)
    end

    AppRecategorizer.recategorize(base_apps, 'Recently Used', '')
  end
end
