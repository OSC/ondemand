# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/workflows/:workflow_id
class WorkflowsController < ApplicationController

  # GET /projects/:id/workflows/:id
  def show
    @project = Project.find(project_id)
    @workflow = Workflow.find(workflow_id, project_directory)
    launcher_ids = @workflow.launcher_ids

    @launchers = Launcher.all(project_directory).select { |l| launcher_ids.include?(l.id) }
  end

  # GET /projects/:id/workflows/new
  def new
    @workflow = Workflow.new(index_params)
    @launchers = Launcher.all(project_directory)
  end

  # GET /projects/:id/workflows/edit
  def edit
    @workflow = Workflow.find(workflow_id, project_directory)
    @launchers = Launcher.all(project_directory)

    return unless @workflow.nil?
    redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id)
  end

  # PATCH /projects/:id/workflows/patch
  def update
    @workflow = Workflow.find(workflow_id, project_directory)

    if @workflow.nil?
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id)
      return
    end

    if @workflow.update(update_params)
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_manifest_updated')
    else
      # TODO: Rename "jobs_project_*"" to "jobs_*" to generalize
      message = if @workflow.errors[:save].empty?
                  I18n.t('dashboard.jobs_project_validation_error')
                else
                  I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
                end
      flash.now[:alert] = message
      render :edit
    end
  end

  # POST /projects/:id/workflows/
  def create
    @workflow = Workflow.new(permit_params)

    if @workflow.save
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_created')
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
    @workflow = Workflow.find(workflow_id, project_directory)

    if @workflow.nil?
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id)
      return
    end

    if @workflow.destroy!
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_deleted')
    else
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
    end
  end

  # POST /projects/:project_id/workflows/:id/submit
  def submit
    @project = Project.find(project_id)
    @workflow = Workflow.find(workflow_id, project_directory)

    result = @workflow.submit(submit_params)
    if result
      redirect_to project_workflow_path(@project.id, @workflow.id), notice: I18n.t('dashboard.jobs_workflow_submitted')
    else
      message = I18n.t('dashboard.jobs_workflow_failed', error: @workflow.collect_errors)
      redirect_to project_workflow_path(@project.id, @workflow.id), alert: message
    end
  end

  private

  def index_params
    params.permit(:project_id).to_h.symbolize_keys
  end

  def project_id
    params.permit(:project_id)[:project_id]
  end

  def workflow_id
    params.require(:id)
  end

  def permit_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, launcher_ids: [])
      .merge(project_dir: project_directory)
  end

  def update_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, launcher_ids: [])
  end

  def submit_params
    params
    .require(:workflow)
    .permit(:name, :description, :id, launcher_ids: [], source_ids: [], target_ids: [])
    .merge(project_dir: project_directory)
  end

  def project_directory
    Project.find(params[:project_id]).directory
  end

end