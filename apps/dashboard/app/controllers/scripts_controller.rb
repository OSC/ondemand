# frozen_string_literal: true

# The controller for apps pages /dashboard/projects/:project_id/scripts
class ScriptsController < ApplicationController

  def new
    @script = Script.new(project_dir: show_script_params[:project_id])
  end

  def show
    project = Project.find(show_script_params[:project_id])
    @script = Script.find(show_script_params[:id], project.directory)

    if cache_file_exists?
      @cache_opts = JSON.parse(cache_file_path, symbolize_names: true)

      @script.smart_attributes.each do |attrib|
        attrib.value = @cache_opts[attrib.id.to_s] if @cache_opts.key?(attrib.id.to_s)
      end
    else
      @cache_opts = {}
    end
  end

  # POST  /dashboard/projects/:project_id/scripts
  def create
    project = Project.find(show_script_params[:project_id])
    opts = { project_dir: project.directory }.merge(create_script_params[:script])
    @script = Script.new(opts)

    if @script.save
      redirect_to project_path(params[:project_id]), notice: 'sucess!'
    else
      redirect_to project_path(params[:project_id]), alert: @script.errors[:save].last
    end
  end

  # POST   /projects/:project_id/scripts/:id/submit
  # submit the job
  def submit
    project = Project.find(params[:project_id])
    @script = Script.find(params[:id], project.directory)
    opts = submit_script_params[:script].to_h.symbolize_keys

    if (job_id = @script.submit(opts))
      @script.write_job_options_to_cache(opts)

      redirect_to(project_path(params[:project_id]), notice: "Successfully submited job #{job_id}.")
    else
      redirect_to(project_path(params[:project_id]), alert: @script.errors[:submit].last)
    end
  end

  private

  def write_job_options_to_cache(opts)
    # Write the opts to a JSON file
    # cache_file = OodAppkit.dataroot.join(@script.project_dir, "#{@script.id}_opts.json")
    File.write(@script.project_dir.join("#{@script.id}_opts.json"), opts.to_json)
  end

  def cache_file_path
    OodAppkit.dataroot.join(@script.project_dir, "#{@script.id}_opts.json")
  end

  def cache_file_exists?
    # Read and parse the saved opts from the JSON file
    # json_file_path = Rails.root.join('tmp', "#{@script.id}_opts.json")
    cache_file_path.exist?
  end

  def create_script_params
    params.permit({ script: [:title] }, :project_id)
  end

  def show_script_params
    params.permit(:id, :project_id)
  end

  def submit_script_params
    keys = @script.smart_attributes.map { |sm| sm.id.to_s }
    params.permit({ script: keys }, :project_id, :id)
  end
end
