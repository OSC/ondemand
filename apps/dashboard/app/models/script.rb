# frozen_string_literal: true

# Script class to handle project scripts and form
class Script
  attr_reader :job_options, :script_file, :script_name

  class << self
    def find(id)
      path = "{project_directory}/.ondemand/scripts/#{id}.yml"
      data = YAML.safe_load(path)
      Script.new(id, data[:title])
    end
  end

  def initialize(id, title)
    @id          = id
    @title       = title
  end

  def save
    path = "#{Project.dataroot}/.ondemand/scripts/#{id}.yml"

    data = {
      tite: title,
    }

    File.write(path, data.to_yaml)
  end
end
