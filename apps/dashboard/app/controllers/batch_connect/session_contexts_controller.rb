# frozen_string_literal: true

# The controller for creating batch connect sessions.
module BatchConnect
  class SessionContextsController < ApplicationController
    include BatchConnectConcern
    include UserSettingStore
    include EncryptedCache

    # GET /batch_connect/<app_token>/session_contexts/new
    def new
      set_app
      set_render_format
      set_session_context
      set_prefill_templates

      session_id = params[:session_id]
      valid_session = session_id && BatchConnect::Session.exist?(session_id)

      if @app.valid?
        begin
          app_parameters_file = valid_session ? BatchConnect::Session.find(session_id).user_defined_context_file : cache_file
          @app.update_session_with_cache(@session_context, app_parameters_file)
        rescue StandardError => e
          flash.now[:alert] = t('dashboard.batch_connect_form_attr_cache_error', error_message: e.message)
        end
      else
        @session_context = nil # do not display session context form
        flash.now[:alert] = @app.validation_reason
      end

      set_app_groups
      set_saved_settings
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
          cache_data = encypted_cache_data(app: @app, data: @session_context.to_openstruct.to_h)
          cache_file.write(cache_data.to_json) # save context to cache file
          save_template
          # We need to set the prefill templates only after storing the new one
          # so that the new one is included / updated in the list
          set_prefill_templates

          format.html do
            redirect_to batch_connect_sessions_url,
                        notice: t('dashboard.batch_connect_sessions_status_blurb_create_success')
          end
          format.json { head :no_content }
        else
          set_prefill_templates
          format.html do
            set_app_groups
            set_saved_settings
            render :new
          end
          format.json { render json: @session_context.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /batch_connect/<app_token>/session_contexts/edit_settings/<settings_name>
    def edit_settings
      set_app
      set_render_format
      set_session_context
      set_prefill_templates

      @template_name = params[:id].to_sym
      settings = @prefill_templates[@template_name]
      if settings.nil?
        redirect_to new_batch_connect_session_context_path(token: @app.token),
                    alert: t('dashboard.bc_saved_settings.missing_settings')
        return
      end

      @session_context.update_with_cache(settings)

      set_app_groups
      set_saved_settings
      set_my_quotas

      render :new
    end

    # POST /batch_connect/<app_token>/session_contexts/save_settings
    def save_settings
      set_app
      set_render_format
      set_session_context

      # Read in context from form parameters
      @session_context.attributes = session_contexts_param

      template_name = params[:template_name]
      save_template

      redirect_to batch_connect_setting_path(token: @app.token, id: template_name),
                  notice: t('dashboard.bc_saved_settings.saved_message', settings_name: template_name)
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

    # Set the all the saved settings to render the navigation
    def set_saved_settings
      @bc_saved_settings = all_bc_templates
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
      @prefill_templates ||= bc_templates(@app)
    end

    def save_template
      return unless params[:save_template].present? && params[:save_template] == 'on' && params[:template_name].present?

      save_bc_template(@app, params[:template_name], @session_context.to_h)
    end

    # Only permit certian parameters
    def session_contexts_param
      if params[:batch_connect_session_context].present?
        params.require(:batch_connect_session_context).permit(@session_context.attributes.keys)
      end
    end

    # Store session context into a cache file
    # @return [Pathname] the cachefile path
    def cache_file
      BatchConnect::Session.cache_root.tap do |p|
        p.mkpath unless p.exist?
      end.join(@app.cache_file)
    end
  end
end
