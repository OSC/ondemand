class MotdFormatterPlaintext

  attr_reader :content

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @content = motd_file.content
  end

  def to_partial_path
    "dashboard/motd_plaintext"
  end

end
