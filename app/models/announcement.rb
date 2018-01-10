class Announcement
  # List of valid announcement types
  TYPES = %i(warning info success danger)

  # The announcement's message
  # @return [String, nil] the announcement's message if it exists
  attr_reader :msg

  # The type of announcement
  # @return [Symbol] the type of announcement
  attr_reader :type

  class << self
    # Parse a file
    # @param path [#to_s] path to file
    # @return [Announcement] announcement object
    def parse(path)
      path = Pathname.new(path.to_s).expand_path

      if path.file? && path.readable?
        case path.extname
        when ".md"
          Announcement.new(msg: path.read)
        when ".yml"
          Announcement.new(YAML.safe_load(ERB.new(path.read, nil, "-").result))
        else
          Announcement.new
        end
      else
        Announcement.new
      end
    end
  end

  # @param opts [#to_h] the announcement object
  # @option opts [#to_sym] :type (:warning) Type of announcement (:info,
  #   :success, :warning, :danger)
  # @option opts [#to_s] :msg (nil) The announcement message
  def initialize(opts = {})
    opts = opts.to_h.symbolize_keys.compact

    type  = opts.fetch(:type, TYPES.first).to_sym
    @type = TYPES.include?(type) ? type : TYPES.first

    msg   = opts.fetch(:msg, "").to_s
    @msg  = msg.blank? ? nil : msg
  end

  # Whether this is a valid announcement
  # @return [Boolean] whether it is valid
  def valid?
    !!msg
  end
end
