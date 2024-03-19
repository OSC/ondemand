# The controller to manage BatchConnect saved settings
class BatchConnect::SettingsController < ApplicationController
  include BatchConnectConcern

  # GET /batch_connect/<app_token>/settings/<settings_name>
  def show
    set_app_groups

    app_token = params[:token]
    settings_name = params[:id]
    @settings = BatchConnect::Settings.find(app_token, settings_name)
    if @settings.outdated?
      flash.now[:alert] = t('dashboard.bc_saved_settings.outdated_message', app_title: @settings.app.title)
    end
  end

  # DELETE /batch_connect/<app_token>/settings/<settings_name>
  def destroy
    app_token = params[:token]
    settings_name = params[:id]
    settings = BatchConnect::Settings.find(app_token, settings_name)
    settings.delete
    redirect_to new_batch_connect_session_context_path(token: app_token),
                notice: t('dashboard.bc_saved_settings.deleted_message', settings_name: settings.name)
  end

  private
  # Set list of app lists for navigation
  def set_app_groups
    @sys_app_groups = bc_sys_app_groups
    @usr_app_groups = bc_usr_app_groups
    @dev_app_groups = bc_dev_app_groups
    @apps_menu_group = bc_custom_apps_group
  end
end
