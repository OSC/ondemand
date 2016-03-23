class MotdFile
  
  # Initialize the Motd Controller object based on the current user.
  #
  # @param [boolean] update_user_view_timestamp True to update the last viewed timestamp. (Default: false)
  def initialize(update_user_view_timestamp: false)
    touch if update_user_view_timestamp
  end

  def motd_config_file
    @motd_config_file ||= "#{ENV['HOME']}/ood_data/.motd"
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

    # get array of sections
    sections = f.split(/^\*+$/).map(&:strip).select { |x| ! x.empty?  }

    # first section is the welcome that never changes
    welcome = sections.shift

    sections_in_markdown = []

    # all other sections follow specific format (we could validate this with regex)
    sections.each do |s|
      # match and capture date,
      # then newline, then three dashes,
      # then capture title with spaces,
      # then newline
      # then capture rest of message
      if s =~ /(\d+\/\d+\/\d+)\n--- ([ \S ]*)\n(.*)/m

        section_object = MotdMessage.new
        section_object.date = $~[1]
        section_object.title = $~[2]
        section_object.body = $~[3]

        sections_in_markdown << section_object
      else
        # not properly formatted
      end
    end

    sections_in_markdown.reverse
  rescue Errno::ENOENT
    # The messages file does not exist on the system.
    # FIXME: Log this somewhere once we port to rails.
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
