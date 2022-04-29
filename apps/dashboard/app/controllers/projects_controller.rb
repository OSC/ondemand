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

    # this validation does not have access to the new name yet to check
    if @project.valid? && @project.update(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_manifest_updated')
    else
      # @project.validate!
      flash[:alert] = @project.errors[:name].last
      redirect_to edit_project_path
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.valid? && @project.save(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      flash[:alert] = @project.errors[:directory].last
      redirect_to new_project_path
    end
  end

  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])

    redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_deleted') if @project.destroy!
  end

  private

  def project_params
    params
      .require(:project)
      .permit(:name, :description, :icon)
  end
end
