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

  private

  def script_params
    params
      .require(:script)
      .permit(
        :name, :batch_connect_form
      )
  end
end
