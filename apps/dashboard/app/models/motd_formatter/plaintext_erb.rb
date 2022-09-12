module MotdFormatter
  # Utility class for rendering plain text MOTD files after ERB rendering them.
  class PlaintextErb
    attr_reader :content, :title

    def initialize(motd_file)
      motd_file = MotdFile.new unless motd_file
      @title = motd_file.title
      @content = ERB.new(motd_file.content).result
    end

    def to_partial_path
      "dashboard/motd_plaintext"
    end
  end
end
