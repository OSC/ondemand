require 'ostruct'

class AppsController < ApplicationController

  def index
    @sys_apps = sys_app_groups
    @dev_apps = OodAppGroup.groups_for(apps: nav_dev_apps)
    @usr_apps = OodAppGroup.groups_for(apps: nav_usr_apps)
    set_metadata_columns
  end

  def featured
    if OodSupport::Process.groups_changed?
      redirect_to apps_restart_url
    else
      @title = nil
      @groups = OodAppGroup.groups_for(apps: nav_usr_apps)
      @motd = MotdFile.new.formatter
      set_my_quotas
    end
  end

  def restart
  end

  def show
    set_app

    raise ActionController::RoutingError.new('Not Found') unless @app.accessible?

    #FIXME: the only thing about this action that feels wrong
    #is it is a GET and we are doing a setup (changing something) in response to
    #this request
    @app.run_setup_production unless @app.dev?

    app_url = @app.url

    if params[:path]
      # if a path in the app is provided, append this to the url
      app_uri = uri(app_url)
      app_uri.path = Pathname.new(app_uri.path).join(params[:path]).to_s
      app_url = app_uri.to_s
    end

    redirect_to app_url

  rescue ::OodApp::SetupScriptFailed => e
    #FIXME: should this be 500 error?
    #FIXME: how we handle setup script failure (etc.) needs rethough and tested
    @app_url = @app.url
    @exception = e
    render "setup_failed"
  end

  def icon
    set_app

    if @app.svg_icon? 
      send_file @app.icon_path, :type => 'image/svg+xml', :disposition => 'inline'
    elsif @app.png_icon?
      send_file @app.icon_path, :type => 'image/png', :disposition => 'inline'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

  def set_app
    r = AppRouter.new(name: params[:name], type: params[:type], owner: params[:owner])
    @app = AppRouter.find(r.token)

    raise ActionController::RoutingError.new('Not Found') if @app.nil?
  end

  def set_metadata_columns
    @metadata_columns = begin
      nav_all_apps.each_with_object([]) do |app, columns|
        app.metadata.each do |k,v|
          columns.append(k.to_s)
        end
      end.uniq.sort_by do |column|
        column.to_s
      end
    end
  end
end
