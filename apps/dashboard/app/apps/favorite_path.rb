# frozen_string_literal: true

# FavoritePath is a class that the dashboard uses to build
# links to various directories.
#
# Sites use initializers to create FavoritePaths and add them to
# OodFilesApp.candidate_favorite_paths.
class FavoritePath
  def initialize(path, title: nil, filesystem: nil)
    @title = title || path.try(:title)
    @path = Pathname.new(path.to_s)
    @filesystem = filesystem || path.try(:filesystem) || 'fs'
  end

  attr_accessor :path, :title, :filesystem

  def remote?
    filesystem != 'fs'
  end

  # FontAwesome icon to use for links
  def icon
    remote? ? 'cloud' : 'folder'
  end

  def to_s
    path.to_s
  end
end
