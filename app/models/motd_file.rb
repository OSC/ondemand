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
  def exist?
    exists = false
    if motd_uri
      begin
        open(motd_uri)
        exists = true
      rescue
        # The messages file does not exist.
        Rails.logger.warn "MOTD File is missing; it was expected at #{motd_uri}"
        exists = false
      end
    end
    exists
  end

  # Create an array of message objects based on the current message of the day.
  def content
    if self.exist?
      open(motd_uri).read
    else
      ""
    end
  end
end



