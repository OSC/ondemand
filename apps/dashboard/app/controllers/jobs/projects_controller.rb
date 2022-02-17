class Jobs::ProjectsController < ApplicationController
  def show
    # files in current project
  end

  def index
    @projects = Jobs::Project.all
  end

  # def new
  #   @project = Jobs::Project.new
  # end

  def create
    @project = Jobs::Project.new(project_params)

    respond_to do |format|
      if @project.save!
        @project.config_dir
        format.html { redirect_to jobs_projects_path, 
          notice: 'Project successfully created!' }
      end
    end
  end

  # DELETE /jobs/projects/.id(.:format)
  def destroy
    Rails.logger.debug("########################")
    Rails.logger.debug("")
    Rails.logger.debug("The destroy params are: #{params}")
    Rails.logger.debug("")
    Rails.logger.debug("########################")


    if @project.destroy!
      respond_to do |format|
        format.html { redirect_to jobs_projects_path, 
          notice: 'Project successfully deleted!' }
      end
    end
  end

  private

    def project_params
      params
        .require(:jobs_project)
        .permit(:dir)
    end
end
