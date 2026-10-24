# frozen_string_literal: true

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
        path = p.expand_path
        path.directory? ? Pathname.glob(path.join('*.{md,yml}')).sort : path
      rescue StandardError
        p
      end.select do |path|
        File.exist?(path)
      end.map do |p|
        Announcement.new(p)
      end

      new(announcements)
    end

    # Build announcements for a Batch Connect app from the configured
    # announcement directories. Sub-app announcements take precedence when
    # present in any configured directory.
    # @param paths [#to_s, Array<#to_s>] configured announcement paths
    # @param token [#to_s] Batch Connect app token
    # @return [Announcements] announcements for the app
    def for_app(paths, token)
      parts = token.to_s.split('/', -1)
      type = parts.first
      app_token_length = type == 'usr' ? 3 : 2

      return new unless %w[sys dev usr].include?(type)
      return new unless [app_token_length, app_token_length + 1].include?(parts.length)
      return new if parts.any? { |part| part.blank? || %w[. ..].include?(part) }

      roots = Array.wrap(paths).filter_map do |path|
        root = Pathname.new(path.to_s).expand_path
        root if root.directory?
      end

      app_paths = if parts.length > app_token_length
                    sub_app_paths = roots.map { |root| root.join('apps', *parts) }.select(&:directory?)
                    sub_app_paths.presence || roots.map { |root| root.join('apps', *parts.first(app_token_length)) }
                  else
                    roots.map { |root| root.join('apps', *parts) }
                  end

      all(app_paths)
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
