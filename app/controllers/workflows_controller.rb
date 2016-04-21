class WorkflowsController < ApplicationController
  before_action :set_workflow, only: [:show, :edit, :update, :destroy, :submit, :copy]

  # GET /workflows
  # GET /workflows.json
  def index
    @workflows = Workflow.preload(:jobs)
  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    @workflow = Workflow.find(params[:id])
    @workflow.jobs.last.update_status! unless @workflow.jobs.last.nil?
  end

  # GET /workflows/new
  def new
    @workflow = Workflow.new
    @templates = Template.all
  end

  # GET /workflows/1/edit
  def edit
  end

  # POST /workflows
  # POST /workflows.json
  def create
    @workflow = Workflow.new(workflow_params)
    @workflow.staged_dir = @workflow.stage.to_s

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

  # PATCH/PUT /workflows/1
  # PATCH/PUT /workflows/1.json
  def update
    respond_to do |format|
      if @workflow.update(workflow_params)
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
    @workflow = Workflow.find(params[:id])
    @workflow.jobs.last.update_status! unless @workflow.jobs.last.nil?

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
    respond_to do |format|
      if @workflow.submitted?
        format.html { redirect_to workflows_url, alert: 'Job has already been submitted.' }
        format.json { head :no_content }
      elsif @workflow.submit
        format.html { redirect_to workflows_url, notice: 'Job was successfully submitted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to workflows_url, alert: "Job failed to be submitted: #{@workflow.errors.to_a}" }
        format.json { render json: @workflow.errors, status: :internal_server_error }
      end
    end
  end

  # PUT /workflows/1/copy
  def copy
    @workflow = @workflow.copy

    respond_to do |format|
      if @workflow.save
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
      params.require(:workflow).permit!
    end
end
