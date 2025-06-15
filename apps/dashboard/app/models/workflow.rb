# frozen_string_literal: true

class Workflow
  include ActiveModel::Model

  class << self
    def workflows_file(project_dir)
      workflows_dir = Pathname.new("#{project_dir}/.ondemand/workflows")
      # TODO: Later use <workflow_id>.yml to get list of all workflows
      # This is similar to lookup file in Project, and will keep list of workflows
      file = workflows_dir.join("workflow.yml")

      FileUtils.mkdir_p(workflows_dir)
      FileUtils.touch(workflows_dir.join("workflow.yml")) unless file.exist?

      file
    end

    def all(project_id)
      project = Project.find(project_id)
      project_dir = project.directory
      f = File.read(workflows_file(project_dir))
      YAML.safe_load(f).to_h.map do |id, workflow_name|
        Workflow.new({ id: id, name: workflow_name })
      end
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{project_dir}/.ondemand/workflows/workflow.yml due to error #{e}")
      {}
    end

    def find(id)
      # TODO: Complete it
    end
  end
  

  def initialize(attributes = {})
    # TODO: Complete it
  end

  # TODO: Add logic to save the DAG relation between launchers like array of <launcher #1, launcher #2>

  # TODO: Add logic to save launcher pairs in the <workflow_id>.yml file and use it in def show() from workflow_controller

end