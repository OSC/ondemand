class Source
  attr_accessor :path, :name

  def initialize(name, path)
    @name = name
    @path = path
  end

  def self.system
    Source.new("System Templates", Rails.root.join('templates').to_s)
  end

  def self.my
    Source.new("My Templates", OodAppkit.dataroot.join("templates").to_s)
  end

  def self.default
    Source.new("Default Templates", Rails.root.join('templates').join("default").to_s)
  end

  def self.default_template
    Source.default.templates.first
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
