class Jobs::ProjectsController < ApplicationController
  def show
    @pwd = Jobs::Project.new.pwd
    @files = Jobs::Project.new.ls
  end

  def index
    @pwd = Jobs::Project.new.pwd
    @files = Jobs::Project.new.ls
  end
end
