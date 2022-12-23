# This is the model project script. It's mostly a data object
class Script
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :name, :directory

  class << self
    def all(project_directory)
      scripts_root = dataroot(project_directory)
      dataroot(project_directory.to_s).children.map do |d|
        Script.new({ :name => d.basename.to_s, :script_dir =>d.to_s }) unless File.basename(d.to_s).start_with?('.')  
      rescue StandardError => e
        Rails.logger.warn("Didn't create project. #{e.message}")
        nil
      end.compact

    end

    def find(project_directory)
      # from_directory(dataroot.join(project_pathname))
    end

    def dataroot(project_directory)
      OodAppkit.dataroot.join("projects/#{project_directory}").tap do |path|
        Pathname.new(path)
      rescue StandardError => e
        Pathname.new('')
      end
    end

    def from_directory(project_directory)
      return nil unless project_directory? && project_directory.executable? && project_directory.readable?
      Script.new()
    end

  end

  # @param router [DevRouter, UsrRouter, SysRouter] router for batch connect
  #   app
  # @param sub_app [String, nil] sub app
  def initialize(attributes = {})
    @name = attributes[:name]
    @directory = attributes[:script_dir]
  end

  

end
