class BatchConnect::SessionsController < ApplicationController
  include BatchConnectConcern

  # GET /batch_connect/sessions
  # GET /batch_connect/sessions.json
  def index
    @sessions = BatchConnect::Session.all
    set_app_groups
    set_my_quotas
  end

  # DELETE /batch_connect/sessions/1
  # DELETE /batch_connect/sessions/1.json
  def destroy
    set_session

    if @session.destroy
      respond_to do |format|
        format.html { redirect_to batch_connect_sessions_url, notice: t('dashboard.batch_connect_sessions_status_blurb_delete_success') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to batch_connect_sessions_url, alert: t('dashboard.batch_connect_sessions_status_blurb_delete_failure') }
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
    end
end
