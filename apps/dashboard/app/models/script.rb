# This is the model project script. It's mostly a data object
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def all
      Log.write($project.inspect)
      
      # dataroot.children.map do |d|
      #   Script.new()
      # rescue StandardError => e
      #   # Rails.logger.warn("Didn't create project. #{e.message}")
      #   # nil
      # end.compact
    end

    def find(project_pathname)
      # from_directory(dataroot.join(project_pathname))
    end

    def dataroot
      Log.write(@project.inspect)
      # OodAppkit.dataroot.join("projects/#{@projects.name}").tap do |path|
      #   # path.mkpath unless path.exist?
      # rescue StandardError => e
      #   # Pathname.new('')
      # end
    end

    def from_directory(project_pathname)
      return nil unless project_pathname.directory? && project_pathname.executable? && project_pathname.readable?
      Script.new()
    end

  end

  # @param router [DevRouter, UsrRouter, SysRouter] router for batch connect
  #   app
  # @param sub_app [String, nil] sub app
  def initialize(attributes = {})
    $project = attributes[:project]
    Script.all
    # Script.all
  end

end
