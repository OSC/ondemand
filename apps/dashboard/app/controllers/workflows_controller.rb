# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/workflows/:workflow_id
class WorkflowsController < ApplicationController
  wrap_parameters false
  
  # GET /projects/:id/workflows/:id
  def show
    return unless load_project_and_workflow_objects
    launcher_ids = @workflow.launcher_ids

    @launchers = Launcher.all(project_directory).select { |l| launcher_ids.include?(l.id) }
  end

  # GET /projects/:id/workflows/new
  def new
    @workflow = Workflow.new(index_params)
    @launchers = Launcher.all(project_directory)
    @workflow_overrides = @workflow.override_attributes
  end

  # GET /projects/:id/workflows/edit
  def edit
    return unless load_project_and_workflow_objects
    @launchers = Launcher.all(project_directory)
    @workflow_overrides = @workflow.override_attributes
  end

  # TODO to remove this with launcher_ids as we will need them after new UI
  # PATCH /projects/:id/workflows/patch
  def update
    return unless load_project_and_workflow_objects

    if @workflow.update(update_params, true)
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_manifest_updated')
    else
      handle_workflow_error(:update)
    end
  end

  # POST /projects/:id/workflows/
  def create
    @workflow = Workflow.new(permit_params)

    if @workflow.save
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_created')
    else
      handle_workflow_error(:create)
    end
  end

  # GET /projects/:id/workflows/:id/clone
  def clone
    return unless load_project_and_workflow_objects

    cloned = @workflow.deep_dup
    cloned.name += " (Copy)"
    session[:cloned_metadata] = cloned.metadata.to_h.deep_stringify_keys
    session[:cloned_advanced_overrides] = cloned.advanced_overrides.to_h.deep_stringify_keys

    @workflow = cloned
    @launchers = Launcher.all(project_directory)
    @workflow_overrides = @workflow.override_attributes

    render :new
  end

  # DELETE /projects/:id/workflows/:id
  def destroy
    return unless load_project_and_workflow_objects

    if @workflow.destroy!
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_deleted')
    else
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
    end
  end

  # POST /projects/:project_id/workflows/:id/save
  def save
    return unless load_project_and_workflow_objects(render_json: true)
    status = @workflow.update(metadata_params(permit_json_data))
    if status
      render json: { message: "Workflow saved successfully" }
    else
      render json: { message: @workflow.collect_errors }, status: :unprocessable_entity
    end
  end

  # GET /projects/:project_id/workflows/:id/load
  def load
    return unless load_project_and_workflow_objects(render_json: true)
    manifest_path = @workflow.manifest_file
    unless File.exist?(manifest_path)
      return render json: { message: 'No saved workflow manifest found.' }, status: :not_found
    end

    data = YAML.load_file(manifest_path)
    metadata = data['metadata'] || {}
    render json: {
      boxes: metadata['boxes'] || [],
      edges: metadata['edges'] || [],
      zoom: metadata['zoom'] || 1.0,
      job_hash: metadata["job_hash"] || {},
      saved_at: metadata['saved_at'] || nil
    }
  end


  # POST /projects/:project_id/workflows/:id/submit
  def submit
    return unless load_project_and_workflow_objects(render_json: true)
    metadata = metadata_params(permit_json_data)
    submit_param = Workflow.build_submit_params(metadata, project_directory)
    result = @workflow.submit(submit_param)
    metadata[:metadata][:job_hash] = result if result.present?
    @workflow.update(metadata)
    if !result.nil?
      render json: { message: I18n.t('dashboard.jobs_workflow_submitted'), job_hash: result }
    else
      msg = I18n.t('dashboard.jobs_workflow_failed', error: @workflow.collect_errors)
      render json: { message: msg }, status: :unprocessable_entity
    end
  end

  private

  def load_project_and_workflow_objects(render_json: false)
    @project = Project.find(project_id)
    @workflow = Workflow.find(workflow_id, project_directory)
    return true if @workflow.present?
    
    if render_json
      render json: { message: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id) }, status: :not_found
    else 
      redirect_to project_path(project_id), notice: I18n.t('dashboard.jobs_workflow_not_found', workflow_id: workflow_id)
    end
    false
  end

  def index_params
    params.permit(:project_id).to_h.symbolize_keys
  end

  def project_id
    params.permit(:project_id)[:project_id]
  end

  def workflow_id
    params.require(:id)
  end

  def permit_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, :sync_key_enabled, launcher_ids: [])
      .merge(
        project_dir: project_directory, metadata: session.delete(:cloned_metadata) || {},
        advanced_overrides: (extract_advanced_overrides || session.delete(:cloned_advanced_overrides) || {}).stringify_keys
      )
  end

  def update_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, :sync_key_enabled, launcher_ids: [])
      .merge(advanced_overrides: (extract_advanced_overrides || {}).stringify_keys)
  end

  # We use launcher's smart-attribute widgets, which render fields with name="launcher[<smart_attribute_id>]".
  # The overrides arrive as params[:launcher], not under params[:workflow].
  def extract_advanced_overrides
    raw = params[:launcher]
    return nil if raw.blank?
    raw = raw.to_unsafe_h if raw.respond_to?(:to_unsafe_h)

    raw.to_h.reject do |k, v|
      k.to_s.end_with?('_min', '_max', '_exclude', '_fixed') || v.blank?
    end
  end

  def project_directory
    Project.find(params[:project_id]).directory
  end

  def permit_json_data
    params.permit(:project_id, :id, :zoom, :saved_at, :start_launcher, boxes: [:id, :title, :row, :col], edges: [:from, :to]).to_h
  end

  def metadata_params(json)
    { 
      metadata: 
      { 
        boxes: json["boxes"] || [], 
        edges: json["edges"] || [], 
        zoom: json["zoom"] || 1.0,
        job_hash: json["job_hash"] || {},
        saved_at: json["saved_at"] || Time.now.to_i,
        start_launcher: json["start_launcher"] || nil
      } 
    }
  end

  def handle_workflow_error(operation)
    # TODO: Rename "jobs_project_*"" to "jobs_*" to generalize
    message =
      if @workflow.errors[:save].empty?
        I18n.t('dashboard.jobs_project_validation_error')
      else
        I18n.t('dashboard.jobs_project_generic_error', error: @workflow.collect_errors)
      end

    flash.now[:alert] = message
    @launchers = Launcher.all(project_directory)
    @workflow_overrides = @workflow.override_attributes
    render operation == :create ? :new : :edit
  end
end