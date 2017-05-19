require 'rss'

class MotdFormatterRss

  attr_reader :content

  # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
  def initialize(motd_file)
    feed = motd_file.content
    @content = RSS::Parser.parse(feed)
  end

  def to_partial_path
    "dashboard/motd_rss"
  end
end
