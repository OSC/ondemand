class MotdFormatterPlaintextErb
  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    @content = render(motd_file)
  end

  def render(motd_file)
    begin
      ERB.new(motd_file.content).result
    rescue Exception => e
      raise "ERB rendering failed with: #{e.message}\n #{motd_file.content}"
    end
  end
 
  def to_partial_path
    "dashboard/motd_plaintext"
  end
end
