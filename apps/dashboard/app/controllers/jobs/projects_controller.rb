# frozen_string_literal: true

module Jobs
  class ProjectsController < ApplicationController
    def show
      # files in current project
    end

    def index
      @projects = Jobs::Project.all
    end

    def new
      @project = Jobs::Project.new
    end

    def edit
      @project = Jobs::Project.find(params[:id])
    end

    def create
      @project = Jobs::Project.new(project_params)

      if @project.save!
        @project.config_dir
        redirect_to jobs_projects_path, notice: 'Project successfully created!'
      else
        redirect_to jobs_projects_path, alert: 'Failed to save project'
      end
    end

    # DELETE /jobs/projects/.id(.:format)
    def destroy
      @project = Jobs::Project.find(params[:id])

      redirect_to jobs_projects_path, notice: 'Project successfully deleted!' if @project.destroy!
    end

    private

    def project_params
      params
        .require(:jobs_project)
        .permit(:dir)
    end
  end
end
