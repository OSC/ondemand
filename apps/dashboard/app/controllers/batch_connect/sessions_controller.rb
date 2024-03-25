# The controller for active batch connect sessions.
class BatchConnect::SessionsController < ApplicationController
  include BatchConnectConcern
  include UserSettingStore

  # GET /batch_connect/sessions
  # GET /batch_connect/sessions.json
  def index
    @sessions = BatchConnect::Session.all
    @sessions.each(&:update_cache_completed!)

    set_app_groups
    set_saved_settings
    set_my_quotas
  end

  # POST /batch_connect/sessions/1/cancel
  # POST /batch_connect/sessions/1/cancel.json
  def cancel
    set_session

    if @session.cancel
      respond_to do |format|
        format.html { redirect_back allow_other_host: false, fallback_location: batch_connect_sessions_url, notice: t("dashboard.batch_connect_sessions_status_blurb_cancel_success") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_back allow_other_host: false, fallback_location: batch_connect_sessions_url, alert: t("dashboard.batch_connect_sessions_status_blurb_cancel_failure") }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batch_connect/sessions/1
  # DELETE /batch_connect/sessions/1.json
  def destroy
    set_session

    if @session.destroy
      respond_to do |format|
        format.html { redirect_back allow_other_host: false, fallback_location: batch_connect_sessions_url, notice: t("dashboard.batch_connect_sessions_status_blurb_delete_success") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_back allow_other_host: false, fallback_location: batch_connect_sessions_url, alert: t("dashboard.batch_connect_sessions_status_blurb_delete_failure") }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = BatchConnect::Session.find(params[:id])
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

    def delete_session_panel?
      params[:delete] ? params[:delete] == 'true' : true
    end
end
