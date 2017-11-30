class Source
  attr_accessor :path, :name

  # Constructor
  # @param [String] name the human readable name of the source
  # @param [String] path the path to the source
  def initialize(name, path)
    @name = name
    @path = path.to_s
  end

  class << self
    # @return [Pathname] path to the system templates
    def system_path
      AppConfig.templates_path
    end

    # @return [Pathname] path to the user templates
    def my_path
      OodAppkit.dataroot.join("templates")
    end

    # @return [Source] A source that has been initialized to the system path.
    def system
      Source.new("System Templates", Source.system_path)
    end

    # @return [Source] A source that has been initialized to the user template path.
    def my
      Source.new("My Templates", Source.my_path)
    end

    # @return [Template] The default template.
    def default_template
      default = Template.new(Rails.root.join("example_templates", "default").to_s, Source.new("Examples", Rails.root.join("example_templates").to_s))
      custom_default = Template.new(Source.system_path.join("default").to_s, Source.system)

      custom_default.exist? ? custom_default : default
    end
  end

  def system?
    @path == Source.system_path.to_s
  end


  def my?
    @path == Source.my_path.to_s
  end

  # @return [Array<Template>] The templates available on the path.
  def templates
    return [] unless Pathname.new(path).directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)
    # Remove any folder that doesn't have a manifest (ex. `.git`)
    folders.delete_if { |f| !File.exist?(Pathname.new(path).join(f).join("manifest.yml")) }

    # create a template for each folder
    folders.map {|f| Template.new(Pathname.new(path).join(f), self) }
  end
end
