# frozen_string_literal: true

# Script class represents the scripts and forms in a project.
# The scripts will sit within the project space.
# The form will sit under the project's configuration directory
# forms take common scheduler commands or options and insert them 
# into scripts selected.
class Script
  include ActiveModel::Model

  attr_reader :script_path, :form_path

  def initialize( script_path: nil, form_path: nil )
    @script_path = script_path
    @form_path   = form_path
  end

  def form_name
    File.basename(form_path, '.yml')
  end

  def script_name
    # include ending for now
    File.basename(script_path)
  end

  def form
    File.open(form_path, 'w') unless form_path.nil?
  end

  def form_attributes
    # hash of form's attrs
    YAML.safe_load(form)
  end

  def save_form
    # write form attrs to script
    form
    file.write(form_attributes)
  end
end
