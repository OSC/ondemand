class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  # TODO Move this to a config location or to the model
  TEMPLATE_PATH = '/nfs/01/wiag/PZS0645/ood/jobconstructor/templates'

  # GET /templates
  # GET /templates.json
  def index
    # Append the system templates to the end of the user defined templates for usability.
    @templates = Template.all.concat(system_templates)
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates
  # POST /templates.json
  def create
    @template = Template.new(template_params)

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


    # Creates an array of template objects based on template folders in TEMPLATE_PATH.
    def system_templates
      templates = Array.new
      folders = Dir.entries(TEMPLATE_PATH)
      # Remove "." and ".."
      folders.shift(2)
      folders.each do |folder|
        template = Template.new
        template.name = folder.titleize
        template.path = "#{TEMPLATE_PATH}/#{folder}/"
        templates.push(template)
      end
      templates
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_template
      # TODO What if this folder is empty? What if it doesn't exist?
      @template = Template.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:name, :path)
    end
end
