# frozen_string_literal: true

module MotdFormatter
  # Utility class for rendering MOTD files in the OSC format.
  class Osc
    attr_reader :content, :title

    # Parse the MOTD in OSC style
    # See: https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day
    #
    # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
    def initialize(motd_file)
      motd_file ||= MotdFile.new
      @title = motd_file.title
      @content = motd_file.content
    end

    Message = Struct.new :date, :title, :body do
      def self.from(str)
        if str =~ %r{(\d+[-/.]\d+[-/.]\d+)\n--- ([ \S ]*)\n(.*)}m
          Message.new(Date.parse(Regexp.last_match(1)), Regexp.last_match(2), Regexp.last_match(3))
        end
      rescue ArgumentError => e
        Rails.logger.warn("MOTD message poorly formatted: #{e} => #{e.message}")

        nil
      end
    end

    def to_partial_path
      'dashboard/motd_osc'
    end

    # since this actually splits the file content into separate messages
    # we can still use this as it is
    def messages
      if content
        # get array of sections which are delimited by a row of ******
        sections = content.split(/^\*+$/).map(&:strip).reject(&:empty?)
        sections.map { |s| Message.from(s) }.compact.sort_by(&:date).reverse
      else
        []
      end
    end
  end
end
