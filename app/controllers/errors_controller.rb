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
    render status: 404, layout: "application"
  end

  # for 500 errors we use the simpler layout with the application links missing
  # because that is one likely area where some complexity in building those
  # links could result in an exception
  def internal_server_error
    @exception  = env['action_dispatch.exception']
    #TODO: log exception information you want to log here
    # after removing it from the normal logging via lograge
    render status: 500
  end
end
