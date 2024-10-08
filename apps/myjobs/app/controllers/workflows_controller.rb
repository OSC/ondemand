# frozen_string_literal: true

class WorkflowsController < ApplicationController
  before_action :update_jobs, only: [:index, :show, :destroy]

  # GET /workflows
  # GET /workflows.json
  def index
    if OODClusters.none?
      msg = 'There are no configured hosts that allow you to submit jobs. Please contact your system administrator.'
      flash.now[:alert] = msg
    end

    @default_template = Template.default
    @templates = Template.all

    @selected_id = session[:selected_id]
    session[:selected_id] = nil
    @workflows = Workflow.eager_load(:jobs)
  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    set_workflow
    @workflow = Workflow.find(params[:id])
    @workflow.jobs.last&.update_status!
  end

  # GET /workflows/new
  def new
    @workflow = Workflow.new
    @templates = Template.all
  end

  def new_from_path
    @workflow = Workflow.new
    @workflow = Workflow.new_from_path(params[:path]) if params[:path]
  end

  # GET /workflows/1/edit
  def edit
    set_workflow
  end

  # POST /workflows
  # POST /workflows.json
  def create
    @templates = Template.all
    @workflow = Workflow.new(workflow_params)

    respond_to do |format|
      if @workflow.save
        session[:selected_id] = @workflow.id
        format.html { redirect_to workflows_url, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /create_default
  # POST /create_default.json
  def create_default
    @templates = Template.all
    @workflow = Workflow.new_from_template(Template.default)

    respond_to do |format|
      if @workflow.save
        format.html { redirect_to workflows_url, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /workflows/create_from_path
  # POST /workflows/create_from_path.json
  def create_from_path
    @workflow = Workflow.new_from_path(workflow_params[:staging_template_dir])
    @workflow.name = workflow_params[:name] unless workflow_params[:name].blank?
    @workflow.batch_host = workflow_params[:batch_host] unless workflow_params[:batch_host].blank?
    @workflow.script_name = workflow_params[:script_name] unless workflow_params[:script_name].blank?
    @workflow.account = workflow_params[:account] unless workflow_params[:account].blank?

    # validate path we are copying from. safe_path is a boolean, error contains the error string if false
    copy_safe, error = Filesystem.new.validate_path_is_copy_safe(@workflow.staging_template_dir.to_s)
    @workflow.errors.add(:staging_template_dir, error) unless copy_safe

    # If the workflow passes validation but a name hasn't been assigned, set the name to the inputted path
    @workflow.name = @workflow.staging_template_dir if @workflow.errors.empty? && @workflow.name.blank?

    respond_to do |format|
      if @workflow.errors.empty? && @workflow.save
        format.html { redirect_to workflows_url, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { render :new_from_path }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workflows/1
  # PATCH/PUT /workflows/1.json
  def update
    set_workflow

    respond_to do |format|
      if @workflow.update(workflow_params)
        session[:selected_id] = @workflow.id
        format.html { redirect_to workflows_path, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @workflow }
      else
        format.html { render :edit }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workflows/1/stop
  def stop
    set_workflow

    @workflow.jobs.last&.update_status!
    session[:selected_id] = @workflow.id

    respond_to do |format|
      if !@workflow.submitted?
        format.html { redirect_to workflows_url, alert: 'Job has not been submitted.' }
        format.json { head :no_content }
      elsif @workflow.stop
        format.html { redirect_to workflows_url, notice: 'Job was successfully stopped.' }
        format.js   { render :show }
        format.json { head :no_content }
      else
        @errors = @workflow.errors
        format.html { redirect_to workflows_url, alert: "Job failed to be stopped: #{@workflow.errors.to_a}" }
        format.json { render json: @workflow.errors, status: :internal_server_error }
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    set_workflow

    respond_to do |format|
      if @workflow.destroy
        format.html { redirect_to workflows_url, notice: 'Job was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to workflows_url, alert: "Job failed to be destroyed: #{@workflow.errors.to_a}" }
        format.json { render json: @workflow.errors, status: :internal_server_error }
      end
    end
  end

  # PUT /workflows/1/submit
  # PUT /workflows/1/submit.json
  def submit
    set_workflow

    # We want to allow the user to resubmit a job that has been run or failed. This will destroy all preexisting
    # job records for this workflow when the job is no longer queued or running, which will clear the submitted state.
    @workflow.jobs.destroy_all if @workflow.submitted? && !@workflow.active?

    respond_to do |format|
      if @workflow.submitted?
        session[:selected_id] = @workflow.id
        format.html { redirect_to workflows_url, alert: 'Job has already been submitted.' }
        format.json { head :no_content }
      elsif @workflow.submit
        session[:selected_id] = @workflow.id
        format.html { redirect_to workflows_url, notice: 'Job was successfully submitted.' }
        format.json { head :no_content }
      else
        # FIXME: instead of alert with html, better to have alert and alert_error_output on flash
        format.html do
          flash = { alert: 'Failed to submit batch job:', alert_error: @workflow.errors.to_a.join("\n") }
          redirect_to(workflows_url, flash: flash)
        end
        format.json { render json: @workflow.errors, status: :internal_server_error }
      end
    end
  end

  # POST /workflows/1/copy
  def copy
    set_workflow

    @workflow = @workflow.copy

    respond_to do |format|
      if @workflow.errors.empty? && @workflow.save
        session[:selected_id] = @workflow.id
        format.html { redirect_to workflows_url, notice: 'Job was successfully copied.' }
        format.json { render :show, status: :created, location: @workflow }
      else
        format.html { redirect_to workflows_url, alert: "Job failed to be copied: #{@workflow.errors.to_a}" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workflow
    @workflow = Workflow.preload(:jobs).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def workflow_params
    params.require(:workflow).permit(
      :name, :batch_host, :script_name, :staging_template_dir,
      :account, :job_array_request, :copy_environment
    )
  end

  def update_jobs
    # get all of the active workflows
    Workflow.preload(:jobs).active.to_a.each(&:update_status!)
  end
end
