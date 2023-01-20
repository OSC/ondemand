# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ScriptsController < ApplicationController
  # GET /projects/:project_id/scripts/:id
  def show
    @scripts = Script.find(params[:id])
  end

  # GET /projects/:project_id/scripts/new
  def new
    if name_nil?
      @project = Project.find(params[:project_id])
      @scripts = Script.new({ category: @project.name })
    else
      returned_params = { name: params[:name], icon: params[:icon] }
      @project = Project.new(returned_params)
    end
  end

  # GET /projects/:project_id/scripts/:id/edit
  def edit
    @project = Project.find(params[:project_id])
    @scripts = Script.new(category: params[:project_id], name: params[:id]).find
  end

  # POST /projects/:project_id/scripts/new
  def create
    @script = Script.new(script_params)
    Rails.logger.debug("GWB create: #{@script.inspect}")
    if @script.save(script_params)
      redirect_to project_url({ id: params[:project_id] })
    else
      redirect_to new_project_script_path
    end
  end

  private

  def name_nil?
    params[:name].nil?
  end

  def script_params
    params
      .require(:script)
      .permit(:subcategory, :name, :description, :icon, :category)
  end
  
end
