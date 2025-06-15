# frozen_string_literal: true

class LauncherWorkflow
  include ActiveModel::Model

  class << self
    attr_accessor :projectroot

    def workflows_file
      Pathname("#{projectroot}/.workflows").tap do |path|
        FileUtils.touch(path.to_s) unless path.exist?
      end
    end

    def workflows
      f = File.read(workflows_file)
      YAML.safe_load(f).to_h
    rescue StandardError, Exception => e
      Rails.logger.warn("cannot read #{projectroot}/.workflows due to error #{e}")
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