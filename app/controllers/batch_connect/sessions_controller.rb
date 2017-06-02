class BatchConnect::SessionsController < ApplicationController
  # GET /batch_connect/sessions
  # GET /batch_connect/sessions.json
  def index
    @sessions = BatchConnect::Session.all

    # FIXME: filter @nav_groups from application controller instead
    # @sys_apps = OodAppGroup.groups_for(apps: SysRouter.apps.select(&:batch_connect_app?))
    @apps = @nav_groups.select(&:has_batch_connect_apps?)
  end

  # DELETE /batch_connect/sessions/1
  # DELETE /batch_connect/sessions/1.json
  def destroy
    set_session

    if @session.destroy
      respond_to do |format|
        format.html { redirect_to batch_connect_sessions_url, notice: 'Session was successfully deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to batch_connect_sessions_url, alert: 'Session failed to be deleted.' }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = BatchConnect::Session.find(params[:id])
    end
end
