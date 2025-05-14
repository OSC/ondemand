# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/launchers
class LaunchersController < ApplicationController

  before_action :find_project
  before_action :find_launcher, only: [:show, :edit, :destroy, :submit, :save]

  SAVE_LAUNCHER_KEYS = [
    :cluster, :auto_accounts, :auto_accounts_exclude, :auto_accounts_fixed,
    :auto_cores, :auto_cores_fixed, :auto_cores_min, :auto_cores_max,
    :auto_scripts, :auto_scripts_exclude, :auto_scripts_fixed,
    :auto_queues, :auto_queues_exclude, :auto_queues_fixed,
    :auto_batch_clusters, :auto_batch_clusters_exclude, :auto_batch_clusters_fixed,
    :bc_num_nodes, :bc_num_nodes_fixed, :bc_num_nodes_min, :bc_num_nodes_max,
    :bc_num_hours, :bc_num_hours_fixed, :bc_num_hours_min, :bc_num_hours_max,
    :auto_job_name, :auto_job_name_fixed,
    :auto_log_location, :auto_log_location_fixed
  ].freeze

  def new
    @launcher = Launcher.new(project_dir: @project.directory)
  end

  # POST  /dashboard/projects/:project_id/launchers
  def create
    opts = { project_dir: @project.directory }.merge(create_launcher_params[:launcher])
    @launcher = Launcher.new(opts)
    default_script_created = @launcher.create_default_script

    if @launcher.save
      notice_messages = [I18n.t('dashboard.jobs_launchers_created')]
      notice_messages << I18n.t('dashboard.jobs_launchers_default_created') if default_script_created
      redirect_to project_path(params[:project_id]), notice: notice_messages.join(' ')
    else
      redirect_to project_path(params[:project_id]), alert: @launcher.errors[:save].last
    end
  end

  # GET   /projects/:project_id/launchers/:id/edit
  # edit
  def edit
  end

  # DELETE /projects/:project_id/launchers/:id
  def destroy
    if @launcher.destroy
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_launchers_deleted')
    else
      redirect_to project_path(params[:project_id]), alert: @launcher.errors[:destroy].last
    end
  end

  # POST   /projects/:project_id/launchers/:id/save
  # save the launcher after editing
  def save
    @launcher.update(save_launcher_params[:launcher])

    if @launcher.save
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_launchers_updated')
    else
      redirect_to project_path(params[:project_id]), alert: @launcher.errors[:save].last
    end
  end

  # POST   /projects/:project_id/launchers/:id/submit
  # submit the job
  def submit
    opts = submit_launcher_params[:launcher].to_h.symbolize_keys

    if (job_id = @launcher.submit(opts))
      redirect_to(project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_launchers_submitted', job_id: job_id))
    else
      redirect_to(project_path(params[:project_id]), alert: @launcher.errors[:submit].last)
    end
  end

  private

  def find_launcher
    @launcher = Launcher.find(show_launcher_params[:id], @project.directory)
    redirect_to(project_path(@project.id), alert: "Cannot find launcher #{show_launcher_params[:id]}") if @launcher.nil?
  end

  def create_launcher_params
    params.permit({ launcher: [:title] }, :project_id)
  end

  def show_launcher_params
    params.permit(:id, :project_id)
  end

  def submit_launcher_params
    keys = @launcher.smart_attributes.map { |sm| sm.id.to_s }
    params.permit({ launcher: keys }, :project_id, :id)
  end

  def save_launcher_params
    auto_env_params = params[:launcher].keys.select do |k|
      k.match?('auto_environment_variable')
    end

    allowlist = SAVE_LAUNCHER_KEYS + auto_env_params

    params.permit({ launcher: allowlist }, :project_id, :id)
  end

  def find_project
    @project = Project.find(show_launcher_params[:project_id])
    redirect_to(projects_path, alert: "Cannot find project: #{show_launcher_params[:project_id]}") if @project.nil?
  end
end
