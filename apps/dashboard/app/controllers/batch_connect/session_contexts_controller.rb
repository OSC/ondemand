# The controller for creating batch connect sessions.
class BatchConnect::SessionContextsController < ApplicationController
  include BatchConnectConcern

  # GET /batch_connect/<app_token>/session_contexts/new
  def new
    set_app
    set_render_format
    set_session_context
    set_prefill_templates

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
        save_template
        # We need to set the prefill templates only after storing the new one
        # so that the new one is included / updated in the list
        set_prefill_templates

        format.html { redirect_to batch_connect_sessions_url, notice: t('dashboard.batch_connect_sessions_status_blurb_create_success') }
        format.json { head :no_content }
      else
        set_prefill_templates
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
      @session_context = @app.build_session_context
    end

    # Set the rendering format for displaying attributes
    def set_render_format
      @render_format = @app.clusters.first.job_config[:adapter] unless @app.clusters.empty?
    end

    # Set the rendering format for displaying attributes
    def set_prefill_templates
      @prefill_templates ||= begin
        return {} unless @app.valid?

        json_path = prefill_templates_root.join("*.json")
        Dir.glob(json_path).map do |path|
          [File.basename(path, '.json'), File.read(path)]
        end.to_h
      end
    end

    def save_template
      return unless params[:save_template].present? && params[:save_template] == "on" && params[:template_name].present?

      safe_name = params[:template_name].gsub(/[\x00\/\\:\*\?\"<>\| ]/, '_')
      path = prefill_templates_root.join(safe_name.to_s + '.json')
      path.write(@session_context.to_json)
    end

    # Only permit certian parameters
    def session_contexts_param
      params.require(:batch_connect_session_context).permit(@session_context.attributes.keys) if params[:batch_connect_session_context].present?
    end

    # Store session context into a cache file
    def cache_file
      BatchConnect::Session.cache_root.tap do |p|
        p.mkpath unless p.exist?
      end.join(@app.cache_file)
    end

    # Root path to the prefill templates
    # @return [Pathname] root directory of prefill templates
    def prefill_templates_root
      cluster = ::Configuration.per_cluster_dataroot? ? cluster_id : nil

      base = BatchConnect::Session.dataroot(@app.token, cluster: cluster)
      base.join('prefill_templates').tap do |p|
        p.mkpath unless p.exist?
      end
    end
end
