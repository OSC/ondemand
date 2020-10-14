class MotdFormatterMarkdownErb
  attr_reader :content, :title

  def initialize(motd_file)
    motd_file ||= MotdFile.new unless motd_file
    @title = motd_file.title
    @content = OodAppkit.markdown.render(render(motd_file))
  end

  def render(motd_file)
    begin
      ERB.new(motd_file.content).result
    rescue Exception => e
      raise e, "ERB Has Failed To Parse The File", motd_file.motd_path
    end
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end
