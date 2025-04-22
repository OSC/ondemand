# frozen_string_literal: true

require 'open-uri'

# The Message of the Day (MOTD) file.
class MotdFile
  attr_reader :motd_path

  # Initialize the Motd Controller object based on the current user.
  #
  # @param [String] path The path to the motd file as a URI
  def initialize(path = ENV['MOTD_PATH'])
    @motd_path = path
    @content = load(path)
  end

  # Checks the path URI to see if it can be opened
  #
  # Uses open-uri to check local or remote path for contents
  # @return [String] the motd raw content as string
  def content
    @content || ''
  end

  # A title for the message of the day.
  #   Set via environment variable 'MOTD_TITLE'
  #   Default: "Message of the Day"
  #
  # @return [String] a string used as the MOTD title
  def title
    ENV['MOTD_TITLE'] || I18n.t('dashboard.motd_title')
  end

  # A factory method that returns an MotdFormatter object
  #
  # @return [Object, nil] an MotdFormatter object that responds to `:to_partial_path`
  #                       `nil` if a file does not exist at the path.
  def formatter
    if exist?
      @motd = case ENV['MOTD_FORMAT']
              when 'osc'
                MotdFormatter::Osc.new(self)
              when 'markdown'
                MotdFormatter::Markdown.new(self)
              when 'markdown_erb'
                MotdFormatter::MarkdownErb.new(self)
              when 'rss'
                MotdFormatter::Rss.new(self)
              when 'text_erb'
                MotdFormatter::PlaintextErb.new(self)
              else
                MotdFormatter::Plaintext.new(self)
              end
    end
  end

  # Is the content present and not empty?
  #
  # @return [Boolean] true if content present
  def exist?
    !@content.nil?
  end

  private

  def load(motd_uri)
    uri = URI.parse(motd_uri)

    case uri.scheme
    when 'http', 'https'
      uri.read
    when nil
      File.read(uri.to_s)
    else
      Rails.logger.warn("Unknown scheme for #{motd_uri}. No MOTD is loaded")
      nil
    end
  rescue Errno::ENOENT
    Rails.logger.warn "MOTD File is missing; it was expected at #{motd_uri}"
    nil
  rescue OpenURI::HTTPError
    Rails.logger.warn "MOTD File is not available at #{motd_uri}"
    nil
  rescue StandardError => e
    Rails.logger.warn "Error opening MOTD at #{motd_uri}\nException: #{e.message}"
    nil
  end
end
