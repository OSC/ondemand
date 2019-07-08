class MotdFormatterMarkdown

  attr_reader :content, :title

  # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    @content = OodAppkit.markdown.render(motd_file.content)
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end
