# frozen_string_literal: true

# The controller for project pages /dashboard/projects/scripts.
class ScriptsController < ApplicationController

  # GET /projects/script/:id
  def show
    @script = Script.find(params[:id])
  end

  # GET /projects/script/new
  def new
    @project = session[:project]
    if name_or_icon_nil?
      @script = Script.new
    else
      returned_params = { name: params[:name], icon: params[:icon] }
      @project = Script.new(returned_params)
    end
  end

  # POST /scripts
  def create
    Log.write("Script params are: #{script_params.inspect}")
    @script = Script.new(script_params)

    if @script.valid? && @script.save(script_params)
      redirect_to scripts_show_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      flash[:alert] = @script.errors[:name].last || @script.errors[:icon].last
      redirect_to new_script_path(name: params[:script][:name], icon: params[:script][:icon])
    end
  end

  private

  def name_or_icon_nil?
    params[:name].nil? || params[:icon].nil?
  end

  def script_params
    params
      .require(:script)
      .permit(:name, :description, :icon)
  end
end
