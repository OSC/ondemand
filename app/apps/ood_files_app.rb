# utility class for dealing with apps that play "files" role
class OodFilesApp
  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    @favorite_paths ||= paths_from_template(ENV['OOD_FILES_PATHS'], basename_filter: ENV['OOD_FILES_PATHS_BASENAME_FILTER']).select {|p|
      p.directory? && p.readable? && p.executable?
    }
  end

  def paths_from_template(templates, basename_filter: nil )
    return [] if templates.nil?

    # get array of string paths
    paths = templates.split(":").map { |t|
      User.new.groups.map(&:name).map { |g| Pathname.new(t % {group: g}) }
    }.flatten.uniq

    # filter by regex (if exist)
    if basename_filter
      rx = Regexp.new(basename_filter)
      paths = paths.select { |p|
        rx.match(p.basename.to_s)
      }
    end

    paths
  end
end
