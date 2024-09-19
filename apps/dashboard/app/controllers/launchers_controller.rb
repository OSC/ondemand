# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class LaunchersController < ApplicationController

  before_action :find_project
  before_action :find_script, only: [:show, :edit, :destroy, :submit, :save]

  SAVE_SCRIPT_KEYS = [
    :cluster, :auto_accounts, :auto_accounts_exclude, :auto_accounts_fixed,
    :auto_cores, :auto_cores_fixed, :auto_cores_min, :auto_cores_max,
    :auto_scripts, :auto_scripts_exclude, :auto_scripts_fixed,
    :auto_queues, :auto_queues_exclude, :auto_queues_fixed,
    :auto_batch_clusters, :auto_batch_clusters_exclude, :auto_batch_clusters_fixed,
    :bc_num_slots, :bc_num_slots_fixed, :bc_num_slots_min, :bc_num_slots_max,
    :bc_num_hours, :bc_num_hours_fixed, :bc_num_hours_min, :bc_num_hours_max,
    :auto_job_name, :auto_job_name_fixed
  ].freeze

  def new
    @script = Launcher.new(project_dir: @project.directory)
  end

  # POST  /dashboard/projects/:project_id/scripts
  def create
    opts = { project_dir: @project.directory }.merge(create_script_params[:launcher])
    @script = Launcher.new(opts)
    default_script_created = @script.create_default_script

    if @script.save
      notice_messages = [I18n.t('dashboard.jobs_scripts_created')]
      notice_messages << I18n.t('dashboard.jobs_scripts_default_created') if default_script_created
      redirect_to project_path(params[:project_id]), notice: notice_messages.join(' ')
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  # GET   /projects/:project_id/scripts/:id/edit
  # edit
  def edit
  end

  # DELETE /projects/:project_id/scripts/:id
  def destroy
    if @script.destroy
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_scripts_deleted')
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:destroy].last
    end
  end

  # POST   /projects/:project_id/scripts/:id/save
  # save the script after editing
  def save
    @script.update(save_script_params[:launcher])

    if @script.save
      redirect_to project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_scripts_updated')
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  # POST   /projects/:project_id/scripts/:id/submit
  # submit the job
  def submit
    opts = submit_script_params[:launcher].to_h.symbolize_keys

    if (job_id = @script.submit(opts))
      redirect_to(project_path(params[:project_id]), notice: I18n.t('dashboard.jobs_scripts_submitted', job_id: job_id))
    else
      redirect_to(project_path(params[:project_id]), alert: @script.errors[:submit].last)
    end
  end

  private

  def find_script
    @script = Launcher.find(show_script_params[:id], @project.directory)
    redirect_to(project_path(@project.id), alert: "Cannot find script #{show_script_params[:id]}") if @script.nil?
  end

  def create_script_params
    params.permit({ launcher: [:title] }, :project_id)
  end

  def show_script_params
    params.permit(:id, :project_id)
  end

  def submit_script_params
    keys = @script.smart_attributes.map { |sm| sm.id.to_s }
    params.permit({ launcher: keys }, :project_id, :id)
  end

  def save_script_params
    auto_env_params = params[:launcher].keys.select do |k|
      k.match?('auto_environment_variable')
    end
    
    allowlist = SAVE_SCRIPT_KEYS + auto_env_params

    params.permit({ launcher: allowlist }, :project_id, :id)
  end

  def find_project
    @project = Project.find(show_script_params[:project_id])
    redirect_to(projects_path, alert: "Cannot find project: #{show_script_params[:project_id]}") if @project.nil?
  end
end
