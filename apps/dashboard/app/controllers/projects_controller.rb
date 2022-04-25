# frozen_string_literal: true

class ProjectsController < ApplicationController
  
  # GET /projects/:id
  def show
    @project = Project.find(params[:id])
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
      redirect_to projects_path, notice: 'Project manifest updated!'
    else
      flash.now[:alert] = @project.errors
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.valid? && @project.save(project_params)
      redirect_to projects_path, notice: 'Project successfully created!'
    else
      redirect_to new_project_path, alert: @project.errors[:directory].last
    end
  end

  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])

    if @project.destroy!
      redirect_to projects_path, notice: 'Project successfully deleted!'
    end
  end

  private
  def project_params
    params
      .require(:project)
      .permit(:name, :description, :icon)
  end
end
