class Source
  attr_accessor :path, :name

  SYSTEM_PATH = Rails.root.join('templates').to_s
  MY_PATH = OodAppkit.dataroot.join("templates").to_s

  # Constructor
  # @param [String] name the human readable name of the source
  # @param [String] path the path to the source
  def initialize(name, path)
    @name = name
    @path = path
  end

  class << self
    # @return [Source] A source that has been initialized to the system path.
    def system
      Source.new("System Templates", SYSTEM_PATH)
    end

    # @return [Source] A source that has been initialized to the user template path.
    def my
      Source.new("My Templates", MY_PATH)
    end

    # @return [Template] The default template.
    def default_template
      default = Template.new(Rails.root.join("example_templates", "default").to_s, Source.new("Examples", Rails.root.join("example_templates").to_s))
      custom_default = Template.new(Rails.root.join("templates", "default").to_s, Source.system)

      custom_default.exist? ? custom_default : default
    end
  end

  def system?
    @path == SYSTEM_PATH
  end


  def my?
    @path == MY_PATH
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
