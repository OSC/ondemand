require "erb/erb_render_helper"

class MotdFormatterPlaintextErb
  include ERBRenderHelper
  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    @content = ERB.new(motd_file.content).result(binding)
  end

  def to_partial_path
    "dashboard/motd_plaintext"
  end
end
