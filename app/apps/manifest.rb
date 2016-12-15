require 'yaml'

class Manifest
  attr_accessor :name, :description
  attr_reader :category, :subcategory, :icon, :role, :url

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

  def defaults
    {"name" => "", "description" => "", "category" => "", "subcategory" => "" , "icon" => "", "role" => "", "url" => ""}
  end

  # Returns the contents of the Manifest object as YAML without the preceding `!ruby/object:Manifest`
  def to_yaml
    self.as_json.to_yaml
  end

  def initialize(opts)
    raise InvalidContentError.new unless(opts && opts.is_a?(Hash))

    # merge with defaults, ignoring nil
    opts = defaults.merge(opts) { |key, oldval, newval| newval || oldval  }

    @name = opts.fetch("name")
    @description = opts.fetch("description")
    @category = opts.fetch("category")
    @subcategory = opts.fetch("subcategory")
    @icon = opts.fetch("icon")
    @role = opts.fetch("role")
    @url = opts.fetch("url")
  end

  def valid?
    true
  end

  def exist?
    true
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

