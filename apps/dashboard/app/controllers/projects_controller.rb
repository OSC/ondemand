# frozen_string_literal: true

class ProjectsController < ApplicationController
  def show
    # files in current project
  end

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
  end

  def create
    @project = Project.new(project_params)

    if @project.save!
      @project.config_dir
      redirect_to projects_path, notice: 'Project successfully created!'
    else
      redirect_to projects_path, alert: 'Failed to save project'
    end
  end

  # DELETE /projects/.id(.:format)
  def destroy
    @project = Project.find(params[:id])

    redirect_to projects_path, notice: 'Project successfully deleted!' if @project.destroy!
  end

  private

  def project_params
    params
      .require(:project)
      .permit(:dir)
  end
end
