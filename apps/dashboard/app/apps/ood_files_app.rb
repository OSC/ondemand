# utility class for dealing with apps that play "files" role
class OodFilesApp
  class << self
    # an array of Pathname objects to check for the existence of and access to
    # should always be []
    # set in config/initializers/ood.rb
    attr_accessor :candidate_favorite_paths
  end
  self.candidate_favorite_paths = []


  # esure that [] is returned if class variable is not set
  def candidate_favorite_paths
    (self.class.candidate_favorite_paths || []).map { |path| FavoritePath.build(path) }
  end

  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    @favorite_paths ||= candidate_favorite_paths.select {|p| p.path.directory? && p.path.readable? && p.path.executable? }
  end

end

class FavoritePath
  
  def initialize(path, title:nil)
    @title = title 
    @path = Pathname.new(path.to_s)
  end

  attr_accessor :path, :title 

  def self.build(path)
    title = path.respond_to?(:title) ? path.title : nil
    FavoritePath.new(path.to_s, title: title)
  end

  def to_s
    path.to_s
  end

end

