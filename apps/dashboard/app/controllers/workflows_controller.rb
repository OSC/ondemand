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
  end

  # GET /projects/:id/workflows/edit
  def edit
    return unless load_project_and_workflow_objects
    @launchers = Launcher.all(project_directory)
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
      saved_at: metadata['saved_at'] || nil
    }
  end


  # POST /projects/:project_id/workflows/:id/submit
  def submit
    return unless load_project_and_workflow_objects(render_json: true)
    metadata = metadata_params(permit_json_data)
    @workflow.update(metadata)
    result = @workflow.submit(submit_params(metadata))
    if result
      render json: { message: "Workflow submitted successfully" }
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
      .permit(:name, :description, :id, launcher_ids: [])
      .merge(project_dir: project_directory)
  end

  def update_params
    params
      .require(:workflow)
      .permit(:name, :description, :id, launcher_ids: [])
  end

  def submit_params(metadata)
    meta = metadata[:metadata] || {}
    { 
      launcher_ids: meta[:boxes].map { |b| b["id"] },
      source_ids: meta[:edges].map { |e| e["from"] },
      target_ids: meta[:edges].map { |e| e["to"] },
      project_dir: project_directory 
    }
  end

  def project_directory
    Project.find(params[:project_id]).directory
  end

  def permit_json_data
    params.permit(:project_id, :id, :zoom, :saved_at, boxes: [:id, :title, :row, :col], edges: [:from, :to]).to_h
  end

  def metadata_params(json)
    { 
      metadata: 
      { 
        boxes: json["boxes"] || [], 
        edges: json["edges"] || [], 
        zoom: json["zoom"] || 1.0, 
        saved_at: json["saved_at"] || Time.now.to_i
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
    render operation == :create ? :new : :edit
  end
end