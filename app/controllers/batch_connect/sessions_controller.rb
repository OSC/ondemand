class BatchConnect::SessionsController < ApplicationController
  # GET /batch_connect/sessions
  # GET /batch_connect/sessions.json
  def index
    @sessions = BatchConnect::Session.all

    # TODO: to correctly do shared apps we should
    #   1. get a list of all batch connect apps, both shared and sys, and then split into groups
    #   2. for shared apps, display the caption below the shared app (i.e. shared by xyz) in the view
    #
    #   UsrRouter.all_apps(owners: UsrRouter.owners) gives all usr apps for all owners
    #
    # TODO: dev apps can be grouped separately
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
