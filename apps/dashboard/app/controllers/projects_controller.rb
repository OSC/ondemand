# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ProjectsController < ApplicationController
  # GET /projects/:id
  def show
    @project = Project.find(show_project_params[:id])
    if @project.nil?
      redirect_to(projects_path, alert: "Cannot find project #{show_project_params[:id]}")
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

    if name_or_icon_nil?
      @project = Project.new
    else
      returned_params = { name: new_project_params[:name], icon: new_project_params[:icon], directory: new_project_params[:directory] }
      @project = Project.new(returned_params)
    end
  end

  # GET /projects/:id/edit
  def edit
    @project = Project.find(show_project_params[:id])

    return unless @project.nil?

    redirect_to(projects_path, alert: "Cannot find project #{show_project_params[:id]}")
  end

  # PATCH /projects/:id
  def update
    @project = Project.find(show_project_params[:id])

    if @project.nil?
      redirect_to(projects_path, alert: "Cannot find project #{show_project_params[:id]}")
    elsif @project.valid? && @project.update(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_manifest_updated')
    else
      flash[:alert] = @project.errors[:name].last || @project.errors[:icon].last
      redirect_to edit_project_path
    end
  end

  # POST /projects
  def create
    Rails.logger.debug("Project params are: #{project_params}")
    id = Project.next_id
    opts = project_params.merge(id: id).to_h.with_indifferent_access
    @project = Project.new(opts)

    if @project.valid? && @project.save(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      # TODO: loop through all errors and show them instead of this
      flash[:alert] = @project.errors[:name].last || @project.errors[:icon].last
      redirect_to new_project_path(name: project_params[:name], directory: project_params[:directory], icon: project_params[:icon])
    end
  end

  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])

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
