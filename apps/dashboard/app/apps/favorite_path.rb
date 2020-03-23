class FavoritePath
  def initialize(path, title:nil)
    @title = title || path.try(:title)
    @path = Pathname.new(path.to_s)
  end

  attr_accessor :path, :title

  def to_s
    path.to_s
  end
end
