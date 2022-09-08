# FavoritePath is a class that the dashboard uses to build
# links to various directories.
#
# Sites use initializers to create FavoritePaths and add them to
# OodFilesApp.candidate_favorite_paths.
class FavoritePath
  def initialize(path, title:nil, filesystem:nil)
    @title = title || path.try(:title)
    @path = Pathname.new(path.to_s)
    @filesystem = filesystem || path.try(:filesystem) || "fs"
  end

  attr_accessor :path, :title, :filesystem

  # Determine whether this FavoritePath is a remote filesystem.
  #
  # @return [Boolean] Whether this FavoritePath is a remote filesystem.
  def remote?
    filesystem != "fs"
  end

  # Get the string representation of this FavoritePath.
  #
  # @return [String] The string representation of this FavoritePath.
  def to_s
    path.to_s
  end
end
