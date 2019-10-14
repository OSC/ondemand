require 'active_model'

class Template
  include ActiveModel::Model
  attr_accessor :path, :source
  delegate :name, :'name=', :notes, :'notes=',:host, :'host=',:script_path, :script, :'script=',to: :manifest

  def persisted?
    false
  end

  # @return [Array<Template>] Returns an array of available templates.
  def self.all
    Source.my.templates.concat(Source.system.templates).sort
  end

  # @return [Template] Return the default template.
  def self.default
    Source.default_template
  end

  def exist?
    path.directory?
  end

  # Constructor
  # @param [String, Pathname] path The template base path.
  # @param [optional, Source] source A Source object based on the template's location.
  def initialize(path, source = Source.new("", Pathname.new("")))
    # We want to convert the full path if a user enters an alias like `~\path`.
    # Calling .expand_path on an invalid location will fail. We rescue here and resort to the user-defined path.
    # Validations that inform the user of the non-existence of the path are handled in the controller.
    @path = expand_pathname_if_valid(path)
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
    self.source.system?
  end

  def default?
    self.path.to_s == Template.default.path.to_s
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

  # Custom sort for templates.
  #   1. Default Template First
  #   2. My templates, alphabetically
  #   3. System templates, alphabetically
  def <=>(o)
    # Default template goes first (there should only be one)
    if self.default?
      return -1
    elsif o.default?
      return 1
    end

    # Sort the remaining templates My > System
    if self.source.my? && o.source.system?
      return -1
    elsif self.source.system? && o.source.my?
      return 1
    end

    # Sort templates by name
    self.name.upcase <=> o.name.upcase
  end

  private

    # Returns an expanded path
    def expand_pathname_if_valid(path)
      if path.blank?
        Pathname.new(path)
      else
        Pathname.new(path).expand_path rescue Pathname.new(path)
      end
    end

end
