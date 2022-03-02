# frozen_string_literal: true

class ProjectsController < ApplicationController
  
  # GET /projects/:id
  def show
    # files in current project
  end

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/:id/edit
  def edit
    @project = Project.find(params[:id])
  end

  # PATCH /projects/:id
  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      @project.write_manifeset
      redirect_to projects_path, notice: 'Project manifest updated!'
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save!
      @project.config_dir
      @project.make_manifest
      redirect_to projects_path, notice: 'Project successfully created!'
    else
      redirect_to projects_path, alert: 'Failed to save project'
    end
  end

  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])

    redirect_to projects_path, notice: 'Project successfully deleted!' if @project.destroy!
  end

  private

  def project_params
    params
      .require(:project)
      .permit(:dir, :icon, :description, :title)
  end
end
