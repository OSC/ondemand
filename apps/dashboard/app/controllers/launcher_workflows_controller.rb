# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/workflows/:workflow_id
class LauncherWorkflowsController < ApplicationController

  # GET /projects/:id/workflows/:id
  def show
    # TODO: Complete it
  end

  # GET /projects/:id/workflows
  def index
    @project = Project.find(params[:project_id])
    LauncherWorkflow.projectroot = @project.directory
    @workflows = LauncherWorkflow.all
  end

  # GET /projects/:id/workflows/new
  def new
    @workflow = LauncherWorkflow.new()
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
    # TODO: Complete it
  end

  # POST /projects/:project_id/workflows/:id/submit
  def submit
    # TODO: Add logic to call submit of each launcher based upon dependency DAG graph
  end

end