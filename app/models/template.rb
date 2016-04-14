require 'active_model'

class Template
  include ActiveModel::Model
  attr_accessor :path
  delegate :name, :'name=', :notes, :'notes=',:host, :'host=',:script_path, :'script=',to: :manifest

  def persisted?
    false
  end

  def self.all
    Source.my.templates.concat(Source.osc.templates)
  end

  def self.default
    Source.default
  end

  def initialize(path)
    @path = Pathname.new(path)
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
