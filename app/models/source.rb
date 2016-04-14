class Source
  attr_accessor :path, :name

  OSC_NAME = "OSC's Templates"
  OSC_SOURCE = Rails.root.join('templates').to_s

  MY_NAME = "My Templates"
  MY_SOURCE = AwesimRails.dataroot.join("templates").to_s

  def initialize(name, path)
    @name = name
    @path = path
  end

  def self.osc
    Source.new(OSC_NAME, OSC_SOURCE)
  end

  def self.my
    Source.new(MY_NAME, MY_SOURCE)
  end

  def self.default
    Pathname.new(OSC_SOURCE).join("default").to_s
  end

  def self.source_name(path)
    (path.include? OSC_SOURCE) ? OSC_NAME : MY_NAME
  end

  def templates
    return [] unless Pathname.new(path).directory?

    folders = Dir.entries(path).sort
    # Remove "." and ".."
    folders.shift(2)

    # create a template for each folder
    folders.map {|f| Template.new(Pathname.new(path).join(f)) }
  end
end
