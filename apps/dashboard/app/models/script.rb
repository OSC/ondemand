# frozen_string_literal: true

# Script class represents the scripts in a project users can interact with.
class Script
  include ActiveModel::Model

  attr_reader :script_path

  def initialize(script_path)
    @script_path = script_path
  end

  def name
    File.basename(script_path, '.yml')
  end

  def attributes
    # hash of file's attrs
  end

  def save
    # write attrs to file
  end
end
