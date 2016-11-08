# utility class for dealing with apps that play "files" role
class OodFilesApp
  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    @favorite_paths ||= paths_from_templates(ENV['OOD_FILES_PATHS'], ENV['OOD_FILES_PATHS_FILTER']).select {|p|
      p.directory? && p.readable? && p.executable?
    }
  end

  def paths_from_templates(templates, filter)
    #TODO:
    []
  end
end
