require 'ostruct'

class AppsController < ApplicationController

  def index
    @type = params[:type]
    @owner = params[:owner]
    @apps = []

    # once these work, we can decide what to do
    # as far as mixing and matching lists of apps
    if @owner == "dev"
      # set apps here
      # fact: we have owner and name
      # so we can use the template for this
      # does the app have owner in it?
      # @apps << OpenStruct.new(name: "weld_predictor")
    elsif @owner == "usr"
    elsif @owner == "sys"
    else
      # user apps
    end
  end

  def show
    type = params[:type]
    owner = params[:owner]
    app_name = params[:name]
    path = params[:path]

    initialize_app_access(type, owner, app_name, path)
    redirect_to app_url(type, owner, app_name, path)

  rescue ::OodApp::SetupScriptFailed => e
    #FIXME: should this be 500 error?
    @app_url = app_url(owner, app_name, path)
    @exception = e
    render "setup_failed"
  end

  private

  # keyword args?
  def router_for_type(type, owner, app_name, path)
    if type.to_sym == :sys
      ::SysRouter.new(app_name)
    elsif type.to_sym == :usr
      ::UsrRouter.new(app_name, owner)
    elsif type.to_sym == :dev
      # FIXME: right now just return my dev apps router
      ::DevRouter.new(app_name)
    else
      #FIXME: app type doesn't exit
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def router_for_owner(owner, app_name, path)
    # TODO
  end


  # initialize app and return the app_url to access
  def initialize_app_access(type, owner, app_name, path)
    router = router_for_type(type, owner, app_name, path)
    app = ::OodApp.new(router)

    # app doesn't exist or you do not have access:
    raise ActionController::RoutingError.new('Not Found') unless app.accessible?


    # run idempotent setup script to setup data for user and handle any errors
    app.run_setup_production
  end

  # get app_url for path to app
  def app_url(type, owner, app_name, path)
    router = router_for_type(type, owner, app_name, path)
    app = ::OodApp.new(router)


    app_url = app.url

    # if a path in the app is provided, append this to the URL
    if path
      app_uri = URI(app_url)
      app_uri.path = Pathname.new(app_uri.path).join(path).to_s
      app_url = app_uri.to_s
    end

    app_url
  end
end
