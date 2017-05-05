class MotdFile
  attr_reader :motd_system_file, :motd_text_format

  Message = Struct.new :date, :title, :body do
    def self.from(str)
      if str =~ /(\d+[-\/\.]\d+[-\/\.]\d+)\n--- ([ \S ]*)\n(.*)/m
        MotdFile::Message.new(Date.parse($1), $2, $3)
      else
        nil
      end
    rescue ArgumentError => e
      Rails.logger.warn("MOTD message poorly formatted: #{e} => #{e.message}")

      nil
    end
  end
  # Initialize the Motd Controller object based on the current user.
  #
  # @param [boolean] update_user_view_timestamp True to update the last viewed timestamp. (Default: false)
  def initialize(path = ENV['MOTD_PATH'], format = ENV['MOTD_FORMAT'], update_user_view_timestamp: false)
    @motd_system_file = path
    @motd_text_format = format
  end

  # An empty file whose modification timestamp indicates the last time the user
  # viewed the motd messages. This is useful for when we want to use the file
  # system to determine when new messages the user has not seen have been
  # added to the motd.
  def motd_config_file
    @motd_config_file ||= OodAppkit.dataroot.join(".motd")
  end

  def exist?
    motd_system_file && File.file?(motd_system_file)
  end

  # Create an array of message objects based on the current message of the day.
  def messages
    f = File.read motd_system_file

    # get array of sections which are delimited by a row of ******
    sections = f.split(/^\*+$/).map(&:strip).select { |x| ! x.empty?  }
    sections.map { |s| MotdFile::Message.from(s) }.compact.sort_by {|s| s.date }.reverse
  rescue Errno::ENOENT
    # The messages file does not exist on the system.
    Rails.logger.warn "MOTD File is missing; it was expected at #{motd_system_file}"
    []
  end
end
