class Jobs::ProjectsController < ApplicationController
  def show
    # files in current project
  end

  def index
    @projects = Jobs::Project.all
  end

  def new
    @project = Jobs::Project.new
  end

  def create
    @project = Jobs::Project.new(project_params)
    Rails.logger.debug("")
    Rails.logger.debug("#################################")
    Rails.logger.debug("project inspect: #{@project.inspect}")
    Rails.logger.debug("project methods: #{@project.methods}")
    @project.

    respond_to do |format|
      if @project.save!
        format.html { redirect_to jobs_projects_path, 
          notice: 'Project successfully created!' }
      end
    end
  end

  def destroy
    # Jobs::Project.find()

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
