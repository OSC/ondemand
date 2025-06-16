# frozen_string_literal: true

class LauncherWorkflow
  include ActiveModel::Model

  class << self
    attr_accessor :project_dir

    def workflows_dir
      Pathname.new("#{project_dir}/.ondemand/workflows")
    end

    def workflows_file
      # TODO: Create directory for each workflow and save workflow.yml inside that directory
      file = workflows_dir.join("workflow.yml")

      FileUtils.mkdir_p(workflows_dir)
      FileUtils.touch(workflows_dir.join("workflow.yml")) unless file.exist?

      file
    end

    def workflows
      f = File.read(workflows_file)
      YAML.safe_load(f).to_h
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{project_dir}/.ondemand/workflows/workflow.yml due to error #{e}")
      {}
    end

    def all
      workflows.map do |id, launcher_pair|
        LauncherWorkflow.new({ id: id, pair: launcher_pair })
      end
    end

    def find(id)
      # TODO: Complete it
    end
  end
  

  def initialize(attributes = {})
    # TODO: Complete it
  end

  # TODO: Add logic to save the DAG relation between launchers like array of <launcher #1, launcher #2>

end