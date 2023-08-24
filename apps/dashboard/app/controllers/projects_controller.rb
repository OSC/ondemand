# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ProjectsController < ApplicationController
  # GET /projects/:id
  def show
    project_id = show_project_params[:id]
    @project = Project.find(project_id)
    if @project.nil?
      redirect_to(projects_path, I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
    else
      @scripts = Script.all(@project.directory)
    end
  end

  # GET /projects
  def index
    @projects = Project.all
    @templates = templates
  end

  # GET /projects/new
  def new
    @templates = new_project_params[:template] == 'true' ? templates : []

    @project = ProjectRequest.new
  end

  # GET /projects/:id/edit
  def edit
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    return unless @project.nil?

    redirect_to(projects_path, alert:  I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
  end

  # PATCH /projects/:id
  def update
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    if @project.nil?
      redirect_to(projects_path, alert: I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
      return
    end

    @project.update(project_params)

    if !@project.valid?
      flash.now[:alert] = I18n.t('dashboard.jobs_project_validation_error')
      render :edit
      return
    end

    if @project.save
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_manifest_updated')
    else
      flash.now[:alert] = I18n.t('dashboard.jobs_project_generic_error', {error: @project.collect_errors})
      render :edit
    end
  end

  # POST /projects
  def create
    @project = ProjectRequest.new(project_request_params.to_h.with_indifferent_access)

    if !@project.valid?
      flash.now[:alert] = I18n.t('dashboard.jobs_project_validation_error')
      render :new
      return
    end

    project_data = @project.to_h
    # DEFAULT VALUES
    id = Project.next_id
    directory = project_data[:directory].blank? ? Project.dataroot.join(id.to_s).to_s : project_data[:directory]
    icon = project_data[:icon].blank? ? 'fas://cog' : project_data[:icon]

    opts = project_data.merge(id: id, directory: directory, icon: icon)
    new_project = Project.new(opts)

    if new_project.save
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      flash.now[:alert] = I18n.t('dashboard.jobs_project_generic_error', {error: new_project.collect_errors})
      render :new
    end
  end



  # DELETE /projects/:id
  def destroy
    project_id = params[:id]
    @project = Project.find(project_id)

    if @project.nil?
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_not_found', project_id: project_id)
      return
    end

    if @project.destroy!
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_deleted')
    else
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_generic_error', {error: @project.collect_errors})
    end
  end

  private

  def templates
    templates = Project.templates.map do |project|
      label = project.title
      data = {
        'data-description' => project.description,
        'data-icon'        => project.icon
      }
      [label, project.directory, data]
    end

    if templates.size.positive?
      templates.prepend(['', '', { 'data-description': '', 'data-icon': '' }])
    else
      []
    end
  end

  def project_params
    params
      .require(:project)
      .permit(:name, :directory, :description, :icon, :id)
  end

  def project_request_params
    params
      .require(:project_request)
      .permit(:name, :directory, :description, :icon)
  end

  def show_project_params
    params.permit(:id)
  end

  def new_project_params
    params.permit(:template, :icon, :name, :directory)
  end
end
