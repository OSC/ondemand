class Source
  attr_accessor :path, :name

  def initialize(name, path)
    @name = name
    @path = path
  end

  def self.osc
    Source.new("OSC's Templates", "/nfs/01/wiag/PZS0645/ood/jobconstructor/templates")
  end

  def self.my
    Source.new("My Templates", AwesimRails.dataroot.join("templates").to_s)
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
