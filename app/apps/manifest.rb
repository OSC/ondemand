require 'yaml'

class Manifest

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
      Manifest.new(YAML.load_file yaml_path)
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
    Manifest.new(YAML.load(yaml))
  rescue Exception => e
    InvalidManifest.new(e)
  end

  # @param [Hash] opts A hash of the options in the manifest
  # @option opts [String] :name The name of the application
  # @option opts [String] :description The description of the application
  # @option opts [String] :category The category of the application
  # @option opts [String] :subcategory The subcategory of the application
  # @option opts [String] :icon The icon used on the dashboard, optionally a Font Awesome tag
  # @option opts [String] :role Dashboard categorization
  # @option opts [String] :url An optional redirect URL
  def initialize(opts)
    raise InvalidContentError.new unless(opts && opts.is_a?(Hash))

    @manifest_options = opts.with_indifferent_access
  end

  # The name of the application
  #
  # @return [String] name as string
  def name
    @manifest_options[:name] || ""
  end

  # The description of the application
  #
  # @return [String] name as string
  def description
    @manifest_options[:description] || ""
  end

  # The icon used on the dashboard, optionally a Font Awesome tag
  #
  # @return [String, nil]
  def icon
    @manifest_options[:icon]
  end

  # Return the optional redirect URL string
  #
  # @return [String, nil]
  def url
    @manifest_options[:url]
  end

  # Return the app category
  #
  # @return [String, nil]
  def category
    @manifest_options[:category]
  end

  # Return the app subcategory
  #
  # @return [String, nil]
  def subcategory
    @manifest_options[:subcategory]
  end

  # Return the app role
  #
  # @return [String, nil]
  def role
    @manifest_options[:role]
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

  def save(path)
    # TODO
  end

  def merge(hash)
    # TODO
  end

  # Creates a hash of the object's current state.
  #
  # @return [Hash] A hash representaion of the Manifest object.
  def to_h
    @manifest_options.compact
  end

  # Returns the contents of the object as a YAML string with the empty values removed.
  #
  # @return [String] The populated contents of the object as YAML string.
  def to_yaml
    self.to_h.as_json.reject { |k, v| v.empty? }.to_yaml
  end

end

class InvalidManifest < Manifest
  attr_reader :exception

  def initialize(exception)
    super({})

    @exception = exception
  end

  def valid?
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
end

