class MotdFormatterPlaintext

  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    file_content =
      # in case ENV[MOTD_FORMAT] = txt_erb
      if ENV['MOTD_FORMAT'].split('_').second.eql?("erb")
        begin
          ERB.new(motd_file.content).result
        rescue
          motd_file.content
        end
      else
        motd_file.content
      end
    @content = file_content
  end

  def to_partial_path
    "dashboard/motd_plaintext"
  end

end
