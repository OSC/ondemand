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

    # need to grab an integer from a lookup file to save based on
    # indexes, so save can have "/scripts/<id>.yml" save
    def get_id
      id = File.read("#{Project.dataroot}/.ondemand/id_file")
      id += 1

      File.write("#{Project.dataroot}/.ondemand/id_file", id)

      id
    end
  end

  def initialize(id: nil, title: nil)
    @id          = id
    @title       = title
  end

  def save
    id = self.id ||= get_id
    
    path = "#{Project.dataroot}/.ondemand/scripts/#{id}.yml"

    data = {
      tite: title,
    }

    File.write(path, data.to_yaml)
  end
end
