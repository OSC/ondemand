# frozen_string_literal: true

# ProjectTemplate classes are used to create a ProjectTemplate from a Project object.
class ProjectTemplate
  include ActiveModel::Model
  include Compressable

  class << self
    def dataroot
      OodAppkit.dataroot.join('templates').tap do |path|
        path.mkpath unless path.exist?
      rescue StandardError => e
        Pathname.new('')
      end
    end
  end

  attr_accessor :id, :project_id, :name, :directory, :description, :icon, :files, :manifest
  def initialize(attributes = {})
    @project_id = attributes[:project_id]
    project = Project.find(project_id)
    @id = project.id
    @name = project.name
    @description = project.description
    @icon = project.icon
    @files = attributes[:files]
    @directory = ProjectTemplate.dataroot.join(id)
  end

  def save
    create_template_directory
    create_manifest
    copy_files
    deflate
  end

  def default_template_directory
    ProjectTemplate.dataroot
  end

  def manifest_path
    directory.join('manifest.yml')
  end

  def files_path
    directory.join('files')
  end
  
  private

  def create_template_directory
    directory.mkpath
  end
  
  def create_files_directory
    files_path.mkpath
  end

  def create_manifest
    File.open(manifest_path, 'w') do |f|
      f.write(ProjectManifest.new(manifest_opts).to_yaml)
      f.close
    end
  end

  def copy_files
    create_files_directory
    files.each{ |file| FileUtils.cp_r(file, files_path.join(file.to_s.split("#{id}/").last)) }
  end

  def manifest_opts
    {
      id: id,
      name: name,
      description: description,
      icon: icon,
      files: files.map{ |file| directory.join(file.to_s).to_s }
    }
  end
end
