# Announcements are the Enumerable collection of the Announcement class.
class Announcements
  include Enumerable

  class << self
    # Build a list of announcements by parsing a list of paths
    # @param paths [#to_s, Array<#to_s>] announcement path or paths
    # @return [Announcements] the parsed announcements
    def all(paths = [])
      paths = Array.wrap(paths).map { |p| Pathname.new(p.to_s) }

      announcements = paths.flat_map do |p|
        begin
          path = p.expand_path
          path.directory? ? Pathname.glob(path.join("*.{md,yml}")).sort : path
        rescue
          p
        end
      end.select do |path|
        File.exist?(path)
      end.map do |p|
        Announcement.new(p)
      end

      new(announcements)
    end
  end

  # @param announcements [Array<Announcement>] list of announcements
  def initialize(announcements = [])
    @announcements = announcements
  end

  # For a block {|announcement| ...}
  # @yield [announcement] Gives the next announcement object in the list
  def each(&block)
    @announcements.each(&block)
  end
end
