# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class ScriptsController < ApplicationController

  def new
    @script = Script.new(project_dir: show_script_params[:project_id])
  end

  def show
    @script = Script.find(show_script_params[:id], show_script_params[:project_id])
  end

  # POST  /dashboard/projects/:project_id/scripts
  def create
    dir = create_script_params[:project_id]
    opts = { project_dir: dir }.merge(create_script_params[:script])
    @script = Script.new(opts)

    if @script.save
      redirect_to project_path(params[:project_id]), notice: 'sucess!'
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  private

  def create_script_params
    params.permit({ script: [:title] }, :project_id)
  end

  def show_script_params
    params.permit(:id, :project_id)
  end
end
