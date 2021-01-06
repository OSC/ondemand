require 'erb_render'

class MotdFormatterPlaintextErb
  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    @content = ERBRender.motd_render_erb(motd_file) 
  end

  def to_partial_path
    "dashboard/motd_plaintext"
  end
end
