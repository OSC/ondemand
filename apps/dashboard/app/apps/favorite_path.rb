class FavoritePath
  def initialize(path, title:nil, filesystem:nil)
    @title = title || path.try(:title)
    @path = Pathname.new(path.to_s)
    @filesystem = filesystem || path.try(:filesystem) || "fs"
  end

  attr_accessor :path, :title, :filesystem

  def remote?
    filesystem != "fs"
  end

  def to_s
    path.to_s
  end
end
