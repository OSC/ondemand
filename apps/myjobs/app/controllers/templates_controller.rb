class TemplatesController < ApplicationController
  before_action :set_template, only: [:destroy]

  # GET /templates/new
  def new
    @template = Template.new("")
    if params[:jobid]
      job = Workflow.find(params[:jobid])
      @template = Template.new(job.staged_dir)
      @template.name = job.name
      @template.host = job.batch_host
      @template.script = job.script_name
    elsif params[:path]
      @template = Template.new(params[:path])
      if params[:host]
        @template.host = params[:host]
      end
    else
      # Template name is a '.' otherwise
      @template.name = ""
    end
  end

  # POST /templates
  # POST /templates.json
  def create

    @template = template_params[:path].blank? ? Template.default : Template.new(template_params[:path])
    @template.script = template_params[:script] if template_params[:script].present?
    @template.name = template_params[:name]
    @template.host = template_params[:host]
    @template.notes = template_params[:notes]

    # TODO this whole create method can be cleaned up
    template_location = Pathname.new(@template.path)

    data_location = OodAppkit.dataroot.join('templates').join(@template.name.parameterize.underscore)

    if data_location.exist? then @template.errors.add(:name, "must be unique.") end
    unless template_location.exist? then @template.errors.add(:path, "does not exist.") end

    # validate path we are copying from. safe_path is a boolean, error contains the error string if false
    copy_safe, error = Filesystem.new.validate_path_is_copy_safe(template_location.to_s)
    @template.errors.add(:path, error) unless copy_safe

    if template_location.file? then @template.errors.add(:path, "must point to a directory.") end

    if @template.errors.empty?
      FileUtils.mkdir_p(data_location)
      copy_dir(template_location, data_location)
      @template.path = data_location.to_s

      yaml = { 'name' => @template.name, 'host' => @template.host, 'notes' => @template.notes, 'script' => @template.script }
      File.open(data_location.join('manifest.yml'), 'w') do |file|
        file.write(yaml.to_yaml)
      end

      saved = true
    end

    respond_to do |format|
      if saved
        format.html { redirect_to new_workflow_path }
        format.json { render action: 'show', status: :created, location: @template }
      else
        format.html { render action: 'new', notice: "error creating template" }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    # Only delete templates inside the app
    if @template.path.to_s.start_with?(OodAppkit.dataroot.join('templates').to_s)
      FileUtils.rm_r @template.path
    end
    respond_to do |format|
      format.html { redirect_to new_workflow_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_template
      # TODO What if this folder is empty? What if it doesn't exist?
      @template = Template.new(params[:path])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:name, :path, :host, :notes, :script)
    end

  # Copies the data in a Location to a destination path using rsync.
  #
  # @param [String, Pathname] dest The target location path.
  # @return [Location] The target location path wrapped by Location instance.
  def copy_dir(src, dest)
    # @path has / auto-dropped, so we add it to make sure we copy everything
    # in the old directory to the new
    `rsync -r --exclude='.svn' --exclude='.git' --exclude='.gitignore' --filter=':- .gitignore' '#{src.to_s}/' '#{dest.to_s}'`

    # return target location so we can chain method
    dest
  end
end
