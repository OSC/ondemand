# utility class for dealing with apps that play "files" role
class OodFilesApp
  class << self
    # an array of Pathname objects to check for the existence of and access to
    # should always be []
    # set in config/initializers/ood.rb
    attr_accessor :candidate_favorite_paths
    attr_accessor :favorite_path_names
  end
  self.candidate_favorite_paths = []
  self.favorite_path_names = Hash.new


  # esure that [] is returned if class variable is not set
  def candidate_favorite_paths
    self.class.candidate_favorite_paths || []
  end

  def favorite_path_names
      self.class.favorite_path_names || Hash.new
  end

  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
     @favorite_paths ||= candidate_favorite_paths.select {|p|
      p.directory? && p.readable? && p.executable?
    }
  end

  def favorite_paths_with_name
      @favorite_paths_with_name ||= favorite_path_names.select {|k,v| k.directory? && k.readable? && k.executable? }
  end


end

