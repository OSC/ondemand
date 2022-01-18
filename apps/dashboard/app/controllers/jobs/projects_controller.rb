class Jobs::ProjectsController < ApplicationController
  def show
    # files in current project
  end

  def index
    @projects = Jobs::Project.all
  end
end
