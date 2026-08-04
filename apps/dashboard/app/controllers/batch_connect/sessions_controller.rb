class BatchConnect::SessionsController < ApplicationController
  include BatchConnectConcern
  include UserSettingStore

  rescue_from BatchConnect::Session::InvalidDbRoot do |exception|
    respond_to do |format|
      format.html do
        redirect_back allow_other_host: false,
                      fallback_location: batch_connect_sessions_url,
                      alert: exception.message
      end
      format.json { render json: { error: exception.message }, status: :internal_server_error }
    end
  end

  # GET /batch_connect/sessions
  # GET /batch_connect/sessions.json
  def index
    begin
      @sessions = BatchConnect::Session.all
      @sessions.each(&:update_cache_completed!)
    rescue BatchConnect::Session::InvalidDbRoot => e
      Rails.logger.error("BatchConnect db_root error: #{e.message}")
      flash.now[:alert] = e.message
      @sessions = []
    end

    set_app_groups
    set_saved_settings
    set_my_quotas
  end

  # ... [keep the rest of the controller untouched] ...
end