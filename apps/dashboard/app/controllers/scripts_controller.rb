# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ScriptsController < ApplicationController
  # GET /projects/:project_id/scripts
  def index
    @project = Project.find(params[:project_id])
    @scripts = Script.all(params[:project_id])
  end

  # GET /projects/:project_id/scripts/new
  def new
    @project = Project.find(params[:project_id])
    @script = Script.new({ project_id: params[:project_id] })
  end

  # POST /projects/:project_id/scripts
  def create
    @script = Script.new(script_params)
    if @script.save
      redirect_to project_path({ id: params[:project_id] }), notice: I18n.t('dashboard.jobs_project_script_created')
    else
      flash[:alert] = @script.errors[:name].last
      redirect_to new_project_script_path(script_params)
    end
  end

  # PUT /projects/:project_id/scripts/:id/submit
  def submit
    @project = Project.find(params[:project_id])
    # @scripts = Script.find(params[:project_id])
    redirect_to project_path({ id: params[:project_id] }), notice: I18n.t('dashboard.jobs_project_script_submitted')
  end

  # DELETE /projects/:project_id/scripts/:id/destroy
  def destroy
    @project = Project.find(params[:project_id])

    redirect_to project_path({ id: params[:project_id] }), notice: I18n.t('dashboard.jobs_project_script_deleted')
  end

  private

  def script_params
    params
      .require(:script)
      .permit(
        :name, :batch_connect_form, :project_id
      )
  end
end
