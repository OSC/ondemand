class AppController < ApplicationController
  def show
    owner = params[:owner]
    app_name = params[:app_name]
    path = params[:path]

    router = ::AppRouter.new(owner)
    myrouter = ::AppRouter.new

    ##########################################################################################
    # this block throws AweSim::App::SetupScriptFailed and/or file not found
    # with custom error page etc.
    # check if this is an actual app, if not, throw an error!
    #
    # FileNotFound or 500 error
    app = AweSim::App.at(path: router.path_for(app: app_name))

    # app doesn't exist or you do not have access:
    raise ActionController::RoutingError.new('Not Found') unless app


    # follow app owner and run setup - both idempotent actions that are safe to
    # run many times
    myrouter.setup_access_to_apps_of(user: owner)
    app_url = router.url_for(app: app_name)

    # if a path in the app is provided, append this to the URL
    if path
      app_uri = URI(app_url)
      app_uri.path = Pathname.new(app_uri.path).join(path).to_s
      app_url = app_uri.to_s
    end


      # run idempotent setup script to setup data for user and handle any errors
        app.run_setup_production

        # i.e.    /awesim_dev/shared_apps/awe0011/comsol_server_on_compute_node/
        redirect_to app_url

  rescue AweSim::App::SetupScriptFailed => e
    #FIXME: should this be 500 error?
    @app_url = app_url
    @exception = e
    render "setup_failed"
  end
end
