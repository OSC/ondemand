require 'yaml'

class Manifest
  attr_reader :name, :provider, :description, :documentation

  class InvalidContentError < StandardError
    def initialize
      super %q(Manifest is not formatted correctly! 
Manifest should be in YAML format with markdown for description and documentation:
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

documentation: |
  Links to support docs should go here.

  * [Company Website](https://www.osc.edu)

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
    {"name" => "", "provider" => "", "description" => "", "documentation" => ""}
  end

  def initialize(opts)
    raise InvalidContentError.new unless(opts && opts.is_a?(Hash))

    # merge with defaults, ignoring nil
    opts = defaults.merge(opts) { |key, oldval, newval| newval || oldval  }

    @name = opts.fetch("name")
    @provider = opts.fetch("provider")
    @description = opts.fetch("description")
    @documentation = opts.fetch("documentation")
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

