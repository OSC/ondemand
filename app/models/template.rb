require 'active_model'

class Template
  include ActiveModel::Model
  attr_accessor :path, :source
  delegate :name, :'name=', :notes, :'notes=',:host, :'host=',:script_path, :'script=',to: :manifest

  def persisted?
    false
  end

  # @return [Array<Template>] Returns an array of available templates.
  def self.all
    Source.my.templates.concat(Source.system.templates)
  end

  # @return [Template] Return the default template.
  def self.default
    Source.default_template
  end

  # Constructor
  # @param [String] path The template base path.
  # @param [optional, Source] source A Source object based on the template's location.
  def initialize(path, source = Source.new("", Pathname.new("")))
    @path = Pathname.new(path)
    @source = source
  end

  def manifest
    @manifest ||= Manifest.load(path.join("manifest.yml"))
  end

  def writable?
    return @writable if defined?(@writable)

    if path && path.directory?
      @writable = path.writable?
    else
      @writable = false
    end

    @writable
  end

  def system?
    true
  end

  # Provide the http path to the file manager
  def file_manager_path
    # Use File.join because URI.join does not respect relative urls
    # TODO: Refactor FileManager into an initializer or helper class.
    #       This will be used elsewhere and often.
    File.join(FileManager[:fs], path.to_s)
  end

  def script_dir
    path.to_s
  end
end
