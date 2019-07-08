class ErrorsController < ApplicationController
  # https://mattbrictson.com/dynamic-rails-error-pages
  #
  # to test in development, comment out this line in
  # config/environments/devleopment.rb:
  #
  #     config.consider_all_requests_local       = true
  #
  # the routes.rb is set to the app to handle exceptions in application.rb
  #
  def not_found
    render status: 404
  end

  def internal_server_error
    @exception  = env['action_dispatch.exception']


    # FIXME: a better solution exists than this
    # avoid rendering nav in case those introduce exceptions
    @hidenav = true

    #TODO: log exception information you want to log here
    # after removing it from the normal logging via lograge
    render status: 500
  end
end
