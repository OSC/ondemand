# The controller for creating batch connect sessions.
class BatchConnect::SessionContextsController < ApplicationController
  include BatchConnectConcern

  # GET /batch_connect/<app_token>/session_contexts/new
  def new
    set_app
    set_render_format
    set_session_context

    if @app.valid?
      begin
        @app.update_session_with_cache(@session_context, cache_file)
      rescue => e
        flash.now[:alert] = t('dashboard.batch_connect_form_attr_cache_error',error_message: e.message)
      end
    else
      @session_context = nil  # do not display session context form
      flash.now[:alert] = @app.validation_reason
    end

    set_app_groups
    set_my_quotas
  end

  # POST /batch_connect/<app_token>/session_contexts
  # POST /batch_connect/<app_token>/session_contexts.json
  def create
    set_app
    set_render_format
    set_session_context

    # Read in context from form parameters
    @session_context.attributes = session_contexts_param

    @session = BatchConnect::Session.new
    respond_to do |format|
      if @session.save(app: @app, context: @session_context, format: @render_format)
        cache_file.write(@session_context.to_json)  # save context to cache file
        format.html { redirect_to batch_connect_sessions_url, notice: t('dashboard.batch_connect_sessions_status_blurb_create_success') }
        format.json { head :no_content }
      else
        format.html do
          set_app_groups
          render :new
        end
        format.json { render json: @session_context.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Set the app from the token
    def set_app
      @app = BatchConnect::App.from_token params[:token]
    end

    # Set list of app lists for navigation
    def set_app_groups
      @sys_app_groups = bc_sys_app_groups
      @usr_app_groups = bc_usr_app_groups
      @dev_app_groups = bc_dev_app_groups
      @apps_menu_group = bc_custom_apps_group
    end

    # Set the session context from the app
    def set_session_context
      Rails.logger.debug("GWB: #{@app.build_session_context.inspect}")

      @session_context = @app.build_session_context
    end

    # Set the rendering format for displaying attributes
    def set_render_format
      @render_format = @app.clusters.first.job_config[:adapter] unless @app.clusters.empty?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_contexts_param
      params.require(:batch_connect_session_context).permit(@session_context.attributes.keys) if params[:batch_connect_session_context].present?
    end

    # Store session context into a cache file
    def cache_file
      BatchConnect::Session.cache_root.tap do |p|
        p.mkpath unless p.exist?
      end.join("#{@app.token.gsub('/', '_')}.json")
    end
end
