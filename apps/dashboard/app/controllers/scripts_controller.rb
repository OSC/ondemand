# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class ScriptsController < ApplicationController

  def new
    @script = Script.new(project_dir: show_script_params[:project_id])
  end

  def show
    project = Project.find(show_script_params[:project_id])
    @script = Script.find(show_script_params[:id], project.directory)
  end

  # POST  /dashboard/projects/:project_id/scripts
  def create
    project = Project.find(show_script_params[:project_id])
    opts = { project_dir: project.directory }.merge(create_script_params[:script])
    @script = Script.new(opts)

    if @script.save
      redirect_to project_path(params[:project_id]), notice: 'sucess!'
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  # POST   /projects/:project_id/scripts/:id/submit
  # submit the job
  def submit
    project = Project.find(params[:project_id])
    @script = Script.find(params[:id], project.directory)
    opts = submit_script_params[:script].to_h.symbolize_keys

    if (job_id = @script.submit(opts))
      redirect_to(project_path(params[:project_id]), notice: "Successfully submited job #{job_id}.")
    else
      redirect_to(project_path(params[:project_id]), alert: @script.errors[:submit].last)
    end
  end

  private

  def create_script_params
    params.permit({ script: [:title] }, :project_id)
  end

  def show_script_params
    params.permit(:id, :project_id)
  end

  def submit_script_params
    keys = @script.smart_attributes.map { |sm| sm.id.to_s }
    params.permit({ script: keys }, :project_id, :id)
  end
end
