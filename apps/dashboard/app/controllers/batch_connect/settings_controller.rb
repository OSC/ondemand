# The controller to manage BatchConnect saved settings
class BatchConnect::SettingsController < ApplicationController
  include BatchConnectConcern
  include UserSettingStore

  # GET /batch_connect/<app_token>/settings/<settings_name>
  def show
    set_app_groups
    set_saved_settings

    settings_params = settings_request_params
    app_token = settings_params[:token]
    settings_name = settings_params[:id]
    settings_values = bc_templates(app_token).fetch(settings_name.to_sym, {})
    @settings = BatchConnect::Settings.new(app_token, settings_name, settings_values)
    if @settings.outdated?
      flash.now[:alert] = t('dashboard.bc_saved_settings.outdated_message', app_title: @settings.app.title)
    end
  end

  # DELETE /batch_connect/<app_token>/settings/<settings_name>
  def destroy
    settings_params = settings_request_params
    app_token = settings_params[:token]
    settings_name = settings_params[:id]
    delete_bc_template(app_token, settings_name)
    redirect_to new_batch_connect_session_context_path(token: app_token),
                notice: t('dashboard.bc_saved_settings.deleted_message', settings_name: settings_name)
  end

  private

  def settings_request_params
    params.permit(:token, :id)
  end

  # Set the all the saved settings to render the navigation
  def set_saved_settings
    @bc_saved_settings = all_bc_templates
  end

  # Set list of app lists for navigation
  def set_app_groups
    @sys_app_groups = bc_sys_app_groups
    @usr_app_groups = bc_usr_app_groups
    @dev_app_groups = bc_dev_app_groups
    @apps_menu_group = bc_custom_apps_group
  end
end
