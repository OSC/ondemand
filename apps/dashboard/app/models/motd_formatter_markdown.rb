class MotdFormatterMarkdown

  attr_reader :content, :title

  # @param [MotdFile] motd_file an MotdFile object that contains a URI path to a message of the day in OSC format
  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    file_content =
      if ENV['MOTD_FORMAT'].split('_').second.eql?("erb")
        begin
          ERB.new(motd_file.content).result
        rescue
          motd_file.content
        end
      else
        motd_file.content
      end
    @content = OodAppkit.markdown.render(file_content)
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end
