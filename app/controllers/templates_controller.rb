class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  # GET /templates
  # GET /templates.json
  def index
    # Append the system templates to the end of the user defined templates for usability.
    @templates = Template.all
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
    # TODO Perform some sort of error checking or validation on params
    if params[:path]
      @template.path = params[:path]
    end
    if params[:host]
      @template.host = params[:host]
    end
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates
  # POST /templates.json
  def create
    @template = Template.new(template_params)

    # TODO this can be cleaned up
    template_location = Pathname.new(@template.path).dirname.cleanpath
    # TODO how to prevent uniques <name>/<number>?
    data_location = AwesimRails.dataroot.join('templates').join(@template.name)
    FileUtils.mkdir_p(data_location)

    if template_location.exist?
      copy_dir(template_location, data_location)
      @template.path = data_location.to_s
    end

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: 'Template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @template }
      else
        format.html { render action: 'new' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to @template, notice: 'Template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_template
      # TODO What if this folder is empty? What if it doesn't exist?
      @template = Template.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:name, :path, :host, :notes)
    end

  # Copies the data in a Location to a destination path using rsync.
  #
  # @param [String, Pathname] dest The target location path.
  # @return [Location] The target location path wrapped by Location instance.
  def copy_dir(src, dest)
    # @path has / auto-dropped, so we add it to make sure we copy everything
    # in the old directory to the new
    `rsync -r --exclude='.svn' --exclude='.git' --exclude='.gitignore' --filter=':- .gitignore' #{src.to_s}/ #{dest.to_s}`

    # return target location so we can chain method
    dest
  end
end
