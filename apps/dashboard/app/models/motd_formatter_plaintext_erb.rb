class MotdFormatterPlaintextErb
  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    @content = render(motd_file.content)
  end

  def render(content)
    begin
      ERB.new(content).result || raise('ERB has failed to parse the file')
    rescue StandardError => e
      puts e.message
      content
    end
  end

  def to_partial_path
    "dashboard/motd_plaintext"
  end
end
