require "tasks/erb_render_utils"

class MotdFormatterMarkdownErb
  attr_reader :content, :title
  include ERBRenderUtils

  def initialize(motd_file)
    motd_file ||= MotdFile.new unless motd_file
    @title = motd_file.title
    @content = OodAppkit.markdown.render(erb(motd_file.content, trim_mode: nil))
  end
  
  def to_partial_path
    "dashboard/motd_markdown"
  end
end
