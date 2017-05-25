require 'open-uri'

class MotdFile

  attr_reader :motd_uri

  # Initialize the Motd Controller object based on the current user.
  #
  # @param [String] path The path to the motd file as a URI
  def initialize(path = ENV['MOTD_PATH'])
    @motd_uri = path
  end

  # Checks the path URI to see if it can be opened
  #
  # Uses open-uri to check local or remote path for contents
  def content
      motd_uri ? open(motd_uri).read : nil
  rescue Errno::ENOENT
    Rails.logger.warn "MOTD File is missing; it was expected at #{motd_uri}"
  rescue OpenURI::HTTPError
    Rails.logger.warn "MOTD File is not available at #{motd_uri}"
  rescue StandardError => ex
    Rails.logger.warn "Error opening MOTD at #{motd_uri}\nException: #{ex}"
  end
end



