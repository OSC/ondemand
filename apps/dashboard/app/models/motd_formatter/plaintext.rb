module MotdFormatter
  # Utility class for rendering plain text MOTD files.
  class Plaintext

    attr_reader :content, :title

    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = motd_file.content
    end

    def to_partial_path
      "dashboard/motd_plaintext"
    end
  end
end
