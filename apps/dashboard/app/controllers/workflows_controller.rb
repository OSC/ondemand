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
    # TODO: Complete it
  end

  # DELETE /projects/:id/workflows/:id
  def destroy
    project_id = params[:project_id]
    workflow_id = params[:id]
    @workflow = Workflow.find(project_id, workflow_id)

    if @workflow.nil?
      redirect_to project_path, notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id)
      return
    end

    if @workflow.destroy!
      redirect_to project_path, notice: I18n.t('dashboard.jobs_workflow_deleted')
    else
      redirect_to project_path, notice: I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
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
      .permit(:name, :description, :id)
      .merge(project_id: params[:project_id])
  end

end