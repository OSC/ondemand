# frozen_string_literal: true

module MotdFormatter
  require 'rss'

  # Utility class for rendering RSS files as the MOTD.
  class Rss
    attr_reader :content, :title

    # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
    def initialize(motd_file)
      motd_file ||= MotdFile.new
      @title = motd_file.title
      @content = parse_rss(motd_file.content)
    end

    def to_partial_path
      'dashboard/motd_rss'
    end

    private

    def parse_rss(rss_content)
      RSS::Parser.parse(rss_content)
    rescue RSS::NotWellFormedError
      Rails.logger.warn 'MOTD is not parseable RSS'
      RSS::Parser.parse('')
    end
  end
end
