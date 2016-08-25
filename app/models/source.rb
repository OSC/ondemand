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

  # @return [Source] A source that has been initialized to the system path.
  def self.system
    Source.new("System Templates", SYSTEM_PATH)
  end

  def system?
    @path == SYSTEM_PATH
  end

  # @return [Source] A source that has been initialized to the user template path.
  def self.my
    Source.new("My Templates", MY_PATH)
  end

  def my?
    @path == MY_PATH
  end

  # @return [Template] The default template.
  def self.default_template
    Template.new(Rails.root.join('templates').join("default").to_s, Source.system)
  end

  # @return [Array<Template>] The templates available on the path.
  def templates
    return [] unless Pathname.new(path).directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)

    # create a template for each folder
    folders.map {|f| Template.new(Pathname.new(path).join(f), self) }
  end
end
