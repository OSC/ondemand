class MotdFormatterMarkdown

  attr_reader :content

  # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @content = OodAppkit.markdown.render(motd_file.content)
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end
