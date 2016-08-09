class Source
  attr_accessor :path, :name

  SYSTEM_PATH = Rails.root.join('templates').to_s
  MY_PATH = OodAppkit.dataroot.join("templates").to_s

  def initialize(name, path)
    @name = name
    @path = path
  end

  def self.system
    Source.new("System Templates", SYSTEM_PATH)
  end

  def system?
    @path == SYSTEM_PATH
  end

  def self.my
    Source.new("My Templates", MY_PATH)
  end

  def my?
    @path == MY_PATH
  end

  def self.default
    Pathname.new(Rails.root.join('templates').to_s).join("default").to_s
  end

  def templates
    return [] unless Pathname.new(path).directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)

    # create a template for each folder
    folders.map {|f| Template.new(Pathname.new(path).join(f), self) }
  end
end
