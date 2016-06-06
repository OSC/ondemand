class MotdFile
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
  def initialize(update_user_view_timestamp: false)
    touch if update_user_view_timestamp
  end

  # An empty file whose modification timestamp indicates the last time the user
  # viewed the motd messages. This is useful for when we want to use the file
  # system to determine when new messages the user has not seen have been
  # added to the motd.
  def motd_config_file
    @motd_config_file ||= OodAppkit.dataroot.join(".motd")
  end

  def motd_system_file
    @motd_system_file ||= "/etc/motd"
  end

  # If the motd file hasn't been created on the system, or if the system motd is newer than the user's file, return true.
  def new_messages?
    # FIXME: Use if/else statements because this is arcane
    (messages.count > 0) ? ( !File.exist?(motd_config_file) ? true : File.new(motd_system_file).ctime > File.new(motd_config_file).ctime ? true : false ) : false   
  end

  # Create an array of message objects based on the current message of the day.
  def messages
    f = File.read motd_system_file

    # get array of sections which are delimited by a row of ******
    sections = f.split(/^\*+$/).map(&:strip).select { |x| ! x.empty?  }
    sections.map! { |s| MotdFile::Message.from(s) }.compact!.sort_by! {|s| s.date }.reverse!
  rescue Errno::ENOENT
    # The messages file does not exist on the system.
    logger.warn "MOTD File is missing; it was expected at #{motd_system_file}"
    []
  end

  # The system will use a file called '.motd' to track when the user last was alerted to messages.
  # This method should be called when the message of the day page is checked so that the dashboard knows when
  # the user last viewed the page.
  #
  # Calling self.touch will create the .motd file, or update the timestamp if it already exists.
  def touch
    FileUtils.mkdir_p(File.dirname(motd_config_file)) unless File.exists?(motd_config_file)
    FileUtils.touch(motd_config_file)
  end
    
end
