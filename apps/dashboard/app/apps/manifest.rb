require 'yaml'

# Manifests provide metadata for applications (OodApps).
class Manifest

  attr_reader :exception

  # InvalidContentError is an error helper class to give users a nice
  # error message when there are validation errors.
  class InvalidContentError < StandardError
    def initialize
      super %q(Manifest is not formatted correctly! 
Manifest should be in YAML format with markdown for description
---
name: Container Fill Sim
description: |
  This is a description.
  With **markdown**.

  And a

  * bullet
    * sub1
    * sub2
  * list

  Support:

  * [Company Website](https://www.osc.edu)

category: OSC
      )
    end
  end

  def self.load(yaml_path)
    if File.exist? yaml_path
      File.open(yaml_path) do |content|
        Manifest.new(YAML.safe_load(content))
      end
    else
      MissingManifest.new({})
    end
  rescue Exception => e
    # FIXME: if we rescue from exceptions, we should store the exception
    # information in the manifest
    # and be explicit about what we are handling
    # probably a YAML formatting error?
    InvalidManifest.new(e)
  end

  def self.load_from_string(yaml)
    Manifest.new(YAML.safe_load(yaml))
  rescue Exception => e
    InvalidManifest.new(e)
  end

  # @param [Hash, Manifest] opts A hash of the options in the manifest.
  # @option opts [String] :name The name of the application.
  # @option opts [String] :description The description of the application.
  # @option opts [String] :category The category of the application.
  # @option opts [String] :subcategory The subcategory of the application.
  # @option opts [String] :icon The icon used on the dashboard, optionally a Font Awesome tag.
  # @option opts [String] :role Dashboard categorization.
  # @option opts [String] :url An optional redirect URL.
  # @option opts [Hash]   :metadata An optional hash of key value pairs.
  # @option opts [Hash]   :tile An optional hash of key value pairs.
  def initialize(opts)
    raise InvalidContentError.new unless(opts && opts.respond_to?(:to_h))

    @manifest_options = opts.to_h.with_indifferent_access.select do |method, _val| 
      respond_to?(method)
    end
  end

  # The name of the application
  #
  # @return [String] name as string
  def name
    @manifest_options[:name] || ""
  end

  # The description of the application
  #
  # @return [String] description as string
  def description
    @manifest_options[:description] || ""
  end

  # The icon used on the dashboard, optionally a Font Awesome tag
  #
  # @return [String] icon as string
  def icon
    @manifest_options[:icon] || ""
  end

  # Return the optional redirect URL string
  #
  # @return [String] url as string
  def url
    @manifest_options[:url] || ""
  end

  # Return the app category
  #
  # @return [String] category as string
  def category
    @manifest_options[:category] || ""
  end

  # Return the app subcategory
  #
  # @return [String] subcategory as string
  def subcategory
    @manifest_options[:subcategory] || ""
  end

  # Return the app role
  #
  # @return [String] role as string
  def role
    @manifest_options[:role] || ""
  end

  # Return the app metadata
  #
  # @return [Hash] metadata as a hash
  def metadata
    @manifest_options[:metadata] || {}
  end

  # Return the app's hint of whether to open app in new window
  #
  # @return [Boolean, nil] if set, Boolean value, otherwise nil
  def new_window
    @manifest_options[:new_window]
  end

  # Return the app's caption
  #
  #  @return [String] caption as string
  def caption
    @manifest_options[:caption].to_s
  end

  # Return the app's tile data. Used to render the pinned app tile
  #
  #  @return [Hash] icon as hash
  def tile
    @manifest_options[:tile] || {}
  end

  # Manifest objects are valid
  #
  # @return [true] Always return true
  def valid?
    true
  end

  # Manifest objects exist
  #
  # @return [true] Always return true
  def exist?
    true
  end

  # Save the current manifest to a path.
  #
  # @param [String, Pathname] path The full path of the file to be saved as string or Pathname object
  #
  # @return [true, false] true if the file is saved successfully
  def save(path)
    Pathname.new(path).write(self.to_yaml)

    true
  rescue
    # TODO Add a custom exception here to track why it erred. IO? Permissions? etc.
    false
  end

  # Merge the contents of a hash into this Manifest's options
  #
  # @param [Hash, Manifest] opts The options to update
  #
  # @return [Manifest] A new manifest with the updated options
  def merge(opts)
    raise InvalidContentError.new unless(opts && opts.respond_to?(:to_h))

    Manifest.new(@manifest_options.merge(opts.to_h))
  end

  # Creates a hash of the object's current state.
  #
  # @return [Hash] A hash representation of the Manifest object.
  def to_h
    @manifest_options.to_h
  end

  # Returns the contents of the object as a YAML string with the empty values removed.
  #
  # @return [String] The populated contents of the object as YAML string.
  def to_yaml
    self.to_h.deep_stringify_keys.compact.to_yaml
  end

  class InvalidManifest < Manifest

    def initialize(exception)
      super({})

      @exception = exception
    end

    def valid?
      false
    end

    def save(path)
      false
    end
  end

  class MissingManifest < Manifest
    def valid?
      false
    end

    def exist?
      false
    end

    def save(path)
      false
    end
  end
end
