# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ScriptsController < ApplicationController
  # GET /projects/:project_id/scripts/new
  def new
    @project = Project.find(params[:project_id])
    @script = Script.new({ project_id: params[:project_id] })
  end

  # POST /projects/:project_id/scripts
  def create
    if params[:script][:name].include?('.')
      flash[:alert] = 'The script name cannot include a period.'
      redirect_to new_project_script_path(script_params)
    else
      @script = Script.new(script_params)
      if @script.save
        redirect_to project_path({ id: params[:project_id] }), notice: I18n.t('dashboard.jobs_project_script_created')
      else
        flash[:alert] = @script.errors[:name].last
        redirect_to new_project_script_path(script_params)
      end
    end
  end

  # DELETE /projects/:project_id/scripts/:id
  def destroy
    Script.destroy(params[:project_id], params[:id])
    redirect_to project_path({ id: params[:project_id] }), notice: I18n.t('dashboard.jobs_project_script_deleted')
  end

  private

  def script_params
    params
      .require(:script)
      .permit(
        :name, :project_id
      )
  end
end
