class MotdFile
  attr_reader :motd_system_file, :motd_text_format, :content


  # Initialize the Motd Controller object based on the current user.
  #
  # @param [String] path The path to the motd file on disk
  def initialize(path = ENV['MOTD_PATH'])
    @motd_system_file = path
  end

  def exist?
    motd_system_file && File.file?(motd_system_file)
  end

  # Create an array of message objects based on the current message of the day.
  def motd_content
    File.read motd_system_file
  rescue Errno::ENOENT
    # The messages file does not exist on the system.
    Rails.logger.warn "MOTD File is missing; it was expected at #{motd_system_file}"
    []
  end

end

class MotdFormatterMarkdown < MotdFile
  def initialize
    super
    @content = OodAppkit.markdown.render(motd_content)
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end

class MotdFormatterPlainText < MotdFile
  def initialize
    super
    @content = motd_content
  end

  def to_partial_path
    "dashboard/motd_text"
  end
end

# Parse the MOTD in OSC style
# See: https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day
class MotdFormatterOsc < MotdFile

  def initialize
    super
  end

  Message = Struct.new :date, :title, :body do
    def self.from(str)
      if str =~ /(\d+[-\/\.]\d+[-\/\.]\d+)\n--- ([ \S ]*)\n(.*)/m
        Message.new(Date.parse($1), $2, $3)
      else
        nil
      end
    rescue ArgumentError => e
      Rails.logger.warn("MOTD message poorly formatted: #{e} => #{e.message}")

      nil
    end
  end

  def to_partial_path
    "dashboard/motd_osc"
  end

  # since this actually splits the file content into separate messages
  # we can still use this as it is
  def messages
    # get array of sections which are delimited by a row of ******
    sections = motd_content.split(/^\*+$/).map(&:strip).select { |x| ! x.empty?  }
    messages = sections.map { |s| Message.from(s) }.compact.sort_by {|s| s.date }.reverse
  end
end
