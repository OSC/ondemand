class Template < ActiveRecord::Base
  has_many :osc_jobs

  TEMPLATE_PATH = '/nfs/01/wiag/PZS0645/ood/jobconstructor/templates'

  # If the template exists but has no id, treat is as one of the system templates.
  def system?
    id.nil?
  end

  # Provide the http path to the file manager
  def file_manager_path
    # Use File.join because URI.join does not respect relative urls
    # TODO: Refactor FileManager into an initializer or helper class.
    #       This will be used elsewhere and often.
    File.join(FileManager[:fs], script_dir)
  end

  def script_dir
    File.dirname(path)
  end

  def folder_contents
    dir = File.dirname(self.path)
    file_paths = []
    Find.find(dir) do |path|
      file_paths << path unless path == dir
    end
    file_paths
  end

  # Creates an array of template objects based on template folders in TEMPLATE_PATH.
  def system_templates
    templates = Array.new
    folders = Dir.entries(TEMPLATE_PATH)

    # Remove "." and ".."
    folders.shift(2)
    folders.each do |folder|
      template = File.exists?(File.join(TEMPLATE_PATH, folder, 'manifest.yml')) ? manifest_template(folder) : non_manifest_template(folder)
      templates.push(template)
    end
    templates
  end

  private

    def manifest_template(folder)
      template = Template.new
      manifest = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{TEMPLATE_PATH}/#{folder}/manifest.yml", __FILE__))))
      template.name = manifest[:name] || folder
      template.path = "#{TEMPLATE_PATH}/#{folder}/#{manifest[:script]}" # TODO Figure out what to do if this is null or does not exist.
      template.host = manifest[:host] || Servers.first[0]
      template.notes = manifest[:notes]
      template
    end

    def non_manifest_template(folder)
      template = Template.new
      template.name = folder.titleize
      # Grab the first file name ending in .sh
      scriptname = Dir.entries("#{TEMPLATE_PATH}/#{folder}/").select{ |f| f =~ /\.sh$/i }.first
      template.path = "#{TEMPLATE_PATH}/#{folder}/#{scriptname}"
      template.host = Servers.first[0]
      template
    end
end
