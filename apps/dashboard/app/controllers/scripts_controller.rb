# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class ScriptsController < ApplicationController

  before_action :find_script, only: [:show, :edit, :submit]

  def new
    @script = Script.new(project_dir: show_script_params[:project_id])
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

  # GET   /projects/:project_id/scripts/:id/edit
  # edit
  def edit
  end

  # POST   /projects/:project_id/scripts/:id/save
  # save the script after editing
  def save
    redirect_to project_path(params[:project_id]), notice: 'TODO'
  end

  # POST   /projects/:project_id/scripts/:id/submit
  # submit the job
  def submit
    opts = submit_script_params[:script].to_h.symbolize_keys

    if (job_id = @script.submit(opts))
      redirect_to(project_path(params[:project_id]), notice: "Successfully submited job #{job_id}.")
    elsif @script.cached_values
      opts = @script.cached_values.to_h.symbolize_keys
      job_id = @script.submit(opts)
      redirect_to(project_path(params[:project_id]), notice: "Successfully submited job #{job_id}.")
    else
      redirect_to(project_path(params[:project_id]), alert: @script.errors[:submit].last)
    end
  end

  private

  def find_script
    project = Project.find(show_script_params[:project_id])
    if project.nil?
      redirect_to(projects_path, alert: "Cannot find project #{show_script_params[:project_id]}")
    else
      @script = Script.find(show_script_params[:id], project.directory)
      redirect_to(project_path(project.id), alert: "Cannot find script #{show_script_params[:id]}") if @script.nil?
    end
  end

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
