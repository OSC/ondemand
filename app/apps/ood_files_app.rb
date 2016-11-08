# utility class for dealing with apps that play "files" role
class OodFilesApp
  class << self
    # an array of Pathname objects to check for the existence of and access to
    # should always be []
    # set in config/initializers/ood.rb
    attr_accessor :candidate_favorite_paths
  end

  # esure that [] is returned if class variable is not set
  def candidate_favorite_paths
    self.class.candidate_favorite_paths || []
  end

  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    @favorite_paths ||= candidate_favorite_paths.select {|p|
      p.directory? && p.readable? && p.executable?
    }
  end

  # build an array of Pathname objects from the specified template string
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
