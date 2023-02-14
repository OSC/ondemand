# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class ScriptsController < ApplicationController

  def new
    @script = Script.new(project_dir: params[:project_id])
  end

  # POST  /dashboard/projects/:project_id/scripts
  def create
    dir = script_params[:project_id]
    opts = { project_dir: dir }.merge(script_params[:script])
    @script = Script.new(opts)

    if @script.save
      redirect_to project_path(params[:project_id]), notice: 'sucess!'
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  private

  def script_params
    params.require(:project_id)
    params.require(:script).permit(:title)
    params.permit({ script: [:title]}, :project_id)
  end
end
