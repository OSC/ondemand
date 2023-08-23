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

    @project = Project.new
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

    if @project.update(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_manifest_updated')
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :edit
    end
  end

  # POST /projects
  def create
    Rails.logger.debug("Project params are: #{project_params}")
    id = Project.next_id
    opts = project_params.merge(id: id).to_h.with_indifferent_access
    @project = Project.new(opts)

    if @project.create
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      # TODO: loop through all errors and show them instead of this
      flash.now[:alert] = @project.errors.full_messages.to_sentence
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

    redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_deleted') if @project.destroy!
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

  def name_or_icon_nil?
    new_project_params[:name].nil? || new_project_params[:icon].nil?
  end

  def project_params
    params
      .require(:project)
      .permit(:name, :directory, :description, :icon, :id)
  end

  def show_project_params
    params.permit(:id)
  end

  def new_project_params
    params.permit(:template, :icon, :name, :directory)
  end
end
