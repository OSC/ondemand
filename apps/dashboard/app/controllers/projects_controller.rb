# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ProjectsController < ApplicationController
  # GET /projects/:id
  def show
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    if @project.nil?
      respond_to do |format|
        message = I18n.t('dashboard.jobs_project_not_found', project_id: project_id)
        format.html { redirect_to(projects_path, alert: message) }
        format.json { render json: { message: message }, status: :not_found }
      end
    else
      @launchers = Launcher.all(@project.directory)
      @valid_project = Launcher.clusters?
      @valid_scripts = Launcher.scripts?(@project.directory)

      alert_messages = []
      alert_messages << I18n.t('dashboard.jobs_project_invalid_configuration_clusters') unless @valid_project
      if @launchers.any? && !@valid_scripts
        alert_messages << I18n.t('dashboard.jobs_project_invalid_configuration_scripts')
      end
      flash.now[:alert] = alert_messages.join(' ') if alert_messages.any?
      respond_to do |format|
        format.html
        format.json { render :show }
      end
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

  # GET /projects/import
  def import
    @project = Project.new
    @projects = Project.possible_imports
  end

  # GET /projects/:id/edit
  def edit
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    return unless @project.nil?

    redirect_to(projects_path, alert: I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
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
      message = if @project.errors[:save].empty?
                  I18n.t('dashboard.jobs_project_validation_error')
                else
                  I18n.t(
                    'dashboard.jobs_project_generic_error', error: @project.collect_errors
                  )
                end
      flash.now[:alert] = message
      render :edit
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      message = if @project.errors[:save].empty?
                  I18n.t('dashboard.jobs_project_validation_error')
                else
                  I18n.t(
                    'dashboard.jobs_project_generic_error', error: @project.collect_errors
                  )
                end
      flash.now[:alert] = message
      @templates = templates if project_params.key?(:template)
      render :new
    end
  end

  # POST /projects/import
  def import_save
    @project = Project.from_directory(project_params[:directory])
    if @project.errors.empty?
      if Project.import_to_lookup(@project)
        redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_imported')
      else
        redirect_to project_import_path, alert: @project.errors.full_messages.join('. ')
      end
    else
      redirect_to project_import_path, alert: @project.errors.full_messages.join('. ')
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
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_generic_error', error: @project.collect_errors)
    end
  end

  # GET /projects/:project_id/jobs/:cluster/:jobid
  def job_details
    project = Project.find(job_details_params[:project_id])
    cluster_str = job_details_params[:cluster].to_s
    cluster = OodAppkit.clusters[cluster_str.to_sym]
    render(:status => 404) if cluster.nil?

    hpc_job = project.job(job_details_params[:jobid].to_s, cluster_str)

    @project = project

    render(partial: 'job_details', locals: { job: hpc_job, project: @project })
  end

  # DELETE /projects/:project_id/jobs/:cluster/:jobid
  def delete_job
    @project = Project.find(job_details_params[:project_id])

    cluster_str = job_details_params[:cluster].to_s

    jobid = job_details_params[:jobid]

    if @project.remove_logged_job(jobid.to_s, cluster_str)
      redirect_to(
        project_path(job_details_params[:project_id]),
        notice: I18n.t('dashboard.jobs_project_job_deleted', job_id: jobid)
      )
    else
      redirect_to(
        project_path(job_details_params[:project_id]),
        alert: I18n.t('dashboard.jobs_project_job_not_deleted', jobid: jobid)
      )
    end
  end

  # POST /projects/:project_id/jobs/:cluster/:jobid/stop
  def stop_job
    @project = Project.find(job_details_params[:project_id])
    cluster_str = job_details_params[:cluster].to_s
    cluster = OodAppkit.clusters[cluster_str.to_sym]

    jobid = job_details_params[:jobid]

    hpc_job = @project.job(jobid.to_s, cluster_str)

    begin
      cluster.job_adapter.delete(jobid.to_s) unless hpc_job.status.to_s == 'completed'
      redirect_to(
        project_path(job_details_params[:project_id]),
        notice: I18n.t('dashboard.jobs_project_job_stopped', job_id: jobid)
      )
    rescue StandardError => e
      redirect_to(
        project_path(job_details_params[:project_id]),
        alert: I18n.t('dashboard.jobs_project_generic_error', error: e.message.to_s)
      )
    end
  end

  private

  def templates
    Project.templates.map do |project|
      label = project.title
      data = {
        'data-description' => project.description,
        'data-icon'        => project.icon
      }
      [label, project.directory, data]
    end
  end

  def project_params
    params
      .require(:project)
      .permit(:name, :directory, :description, :icon, :id, :template)
  end

  def show_project_params
    params.permit(:id)
  end

  def new_project_params
    params.permit(:template, :icon, :name, :directory)
  end

  def job_details_params
    params.permit(:project_id, :cluster, :jobid)
  end
end
