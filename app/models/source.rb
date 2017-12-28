class Source
  attr_reader :path, :name

  # Constructor
  # @param [String] name the human readable name of the source
  # @param [Pathname] path the path to the source
  def initialize(name, path)
    @name = name
    @path = Pathname.new(path)
  end

  class << self
    # @return [Source] A source that has been initialized to the system path.
    def system
      Source.new("System Templates", Configuration.templates_path)
    end

    # @return [Source] A source that has been initialized to the user template path.
    def my
      Source.new("My Templates", OodAppkit.dataroot.join("templates"))
    end

    # @return [Template] The default template.
    def default_template
      default = Template.new(Rails.root.join("example_templates", "default"), Source.new("Examples", Rails.root.join("example_templates")))
      custom_default = Template.new(Source.system.path.join("default"), Source.system)

      custom_default.exist? ? custom_default : default
    end
  end

  def system?
    @path == Source.system.path
  end


  def my?
    @path == Source.my.path
  end

  # @return [Array<Template>] The templates available on the path.
  def templates
    return [] unless path.directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)
    # Remove any folder that doesn't have a manifest (ex. `.git`)
    folders.delete_if { |f| ! path.join(f).join("manifest.yml").exist? }

    # create a template for each folder
    folders.map {|f| Template.new(path.join(f), self) }
  end
end
