require 'yaml'

class Manifest
  attr_reader :name, :description, :category, :subcategory, :icon

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
    {"name" => "", "description" => "", "category" => "", "subcategory" => "" , "icon" => "fa://gear"}
  end

  def default_icon_uri
    URI.parse(defaults["icon"])
  end

  def icon_uri
    uri = URI.parse(icon)

    # only support fa scheme for now
    if uri.scheme != "fa"
      default_icon_uri
    else
      uri
    end
  rescue
    default_icon_uri
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

