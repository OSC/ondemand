# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/workflows/:workflow_id
class WorkflowsController < ApplicationController

  # GET /projects/:id/workflows/:id
  def show
    # TODO: Complete it
  end

  # GET /projects/:id/workflows/new
  def new
    @workflow = Workflow.new(index_params)
    @launchers = Launcher.all(project_directory)
  end

  # GET /projects/:id/workflows/edit
  def edit
    # TODO: Complete it
  end

  # PATCH /projects/:id/workflows/patch
  def update
    # TODO: Complete it
  end

  # POST /projects/:id/workflows/
  def create
    @workflow = Workflow.new(permit_params)
    Rails.logger.warn(params[:workflow][:launcher_ids])

    if @workflow.save
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_workflow_created')
    else
      # TODO: Rename "jobs_project_*"" to "jobs_*" to generalize
      message = if @workflow.errors[:save].empty?
                  I18n.t('dashboard.jobs_project_validation_error')
                else
                  I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
                end
      flash.now[:alert] = message
      render :new
    end
  end

  # DELETE /projects/:id/workflows/:id
  def destroy
    @workflow = Workflow.find(params[:id], project_directory)

    if @workflow.nil?
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: params[:id])
      return
    end

    if @workflow.destroy!
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_workflow_deleted')
    else
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
    end
  end

  # POST /projects/:project_id/workflows/:id/submit
  def submit
    # TODO: Add logic to call submit of each launcher based upon dependency DAG graph
  end

  private

  def index_params
    params.permit(:project_id).to_h.symbolize_keys
  end

  def permit_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, launcher_ids: [])
      .merge(project_dir: project_directory)
  end

  def project_directory
    project_dir = Project.find(params[:project_id]).directory
  end

end