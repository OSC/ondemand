class BatchConnect::SessionContextsController < ApplicationController
  include BatchConnectConcern

  # GET /batch_connect/<app_token>/session_contexts/new
  def new
    set_app
    set_render_format
    set_session_context

    if @app.valid?
      # Read in context from cache file
      @session_context.from_json(cache_file.read) if cache_file.file?
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
    set_session_context
    set_specified_cluster

    # Read in context from form parameters
    @session_context.attributes = session_contexts_params

    @session = BatchConnect::Session.new
    respond_to do |format|
      if @cluster && @session.save(app: @app, context: @session_context, format: @cluster.job_config[:adapter], cluster_id: @cluster.id)
        cache_file.write(@session_context.to_json)  # save context to cache file
        format.html { redirect_to batch_connect_sessions_url, notice: t('dashboard.batch_connect_sessions_status_blurb_create_success') }
        format.json { head :no_content }
      else
        @session.errors.add(:base, :cluster_not_specified, "A valid cluster to submit to has not been specified.") unless @cluster

        format.html do
          set_app_groups
          render :new
        end
        format.json { render json: @session_context.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_specified_cluster
      permitted_params = session_contexts_params

      if @app.cluster_dependencies.one?
        @cluster = @app.cluster_dependencies.first
      elsif @app.cluster_dependencies.any? && permitted_params[:batch_connect_session_context] && permitted_params[:batch_connect_session_context][:cluster]
        cluster = @app.cluster_dependencies.find { |cluster| cluster.id == permitted_params[:batch_connect_session_context][:cluster] }
      end
    end

    # Set the app from the token
    def set_app
      @app = BatchConnect::App.from_token params[:token]
    end

    # Set list of app lists for navigation
    def set_app_groups
      @sys_app_groups = bc_sys_app_groups
      @usr_app_groups = bc_usr_app_groups
      @dev_app_groups = bc_dev_app_groups
    end

    # Set the session context from the app
    def set_session_context
      @session_context = @app.build_session_context
    end


    def set_render_format
      adapters = @app.cluster_dependencies.map { |cluster|
        cluster.job_config[:adapter]
      }.compact.uniq

      # FIXME: not sure if we want to write a warning or display a message
      # seems like you could write custom JavaScript to address the potential
      # prbblems, and that we would only want to display, perhaps in the help
      # text of a smart attribute that requires a specific format to display
      # correctly
      #
      # a better solution might be to have render_format be an array of formats
      # and each smart attribute handle problematic input appropriately
      #
      # @render_format and @render_formats, for example, as separate arguments
      #
      # if(adapters.count > 1)
      #   logger.warn "Displaying form with cluster dependency list of multiple adapters that this user can submit jobs to"
      # elsif adapters.count == 0
      #   logger.warn "Displaying form with no valid cluster depenenecy specified that this user can submit jobs to"
      # end

      @render_format = adapters.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_contexts_params
      # FIXME: this may cause problems too - it prevents sending in the web
      # form any form "attribute" that is not specified as an attribute in the yaml file
      params.require(:batch_connect_session_context).permit(@session_context.attributes.keys + [:cluster])
    end

    # Store session context into a cache file
    def cache_file
      BatchConnect::Session.dataroot(@app.token).tap { |p| p.mkpath unless p.exist? }.join("context.json")
    end
end
