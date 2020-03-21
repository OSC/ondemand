class FavoritePath
  def initialize(path, title:nil)
    @title = title
    @path = Pathname.new(path.to_s)
  end

  attr_accessor :path, :title

  def self.build(path)
    FavoritePath.new(path.to_s, title: path.try(:title))
  end

  def to_s
    path.to_s
  end
end
