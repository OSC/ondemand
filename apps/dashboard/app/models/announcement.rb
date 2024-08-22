# frozen_string_literal: true

# Announcements show up on the dashboard to convey a message to users.
class Announcement
  include UserSettingStore
  # List of valid announcement types
  TYPES = [:warning, :info, :success, :danger].freeze

  # @param opts [#to_h, #to_s] the announcement object or path
  # @option opts [#to_sym] :type (:warning) Type of announcement (:info,
  #   :success, :warning, :danger)
  # @option opts [#to_s] :msg (nil) The announcement message
  def initialize(opts = {})
    if opts.respond_to? :to_h
      @opts = opts.to_h
    else
      @path = Pathname.new(opts.to_s)
    end
  end

  # The type of announcement
  # @return [Symbol] the type of announcement
  def type
    type = opts.fetch(:type, TYPES.first).to_sym
    TYPES.include?(type) ? type : TYPES.first
  end

  # The announcement's message
  # @return [String, nil] the announcement's message if it exists
  def msg
    msg = opts.fetch(:msg, '').to_s
    msg.blank? ? nil : msg
  end

  # The announcement's id. Used when storing that it has been dismissed.
  #  @return [String] the id
  def id
    @id ||= begin
              default_id = Digest::SHA1.hexdigest(msg) if msg
              opts.fetch(:id, default_id)
            end
  end

  # The announcement's button text displayed for required or dismissible announcements
  #  @return [String] the button text
  def button_text
    default_text = required? ? I18n.t('dashboard.announcements_required_button') : I18n.t('dashboard.announcements_dismissible_button')
    opts.fetch(:button_text, default_text).to_s
  end

  # Whether this is a valid announcement
  # @return [Boolean] whether it is valid
  def valid?
    return false unless msg

    return false if dismissible? && !id

    true
  end

  # Whether this announcement has been dismissed.
  # @return [Boolean] whether it has been dismissed
  def completed?
    dismissible? && user_settings.dig(:announcements, id.to_s.to_sym).present?
  end

  # Whether this is a dismissible announcement.
  # @return [Boolean] whether it is dismissible
  def dismissible?
    required? || opts.fetch(:dismissible, true)
  end

  # Whether this is a required announcement.
  # @return [Boolean] whether it is required
  def required?
    opts.fetch(:required, false)
  end

  private

  def opts
    @opts ||= case @path.extname
              when '.md'
                { msg: @path.expand_path.read }
              when '.yml'
                YAML.safe_load(ERB.new(@path.expand_path.read, trim_mode: '-').result)
              else
                {}
              end
    @opts.symbolize_keys.compact
  rescue Errno::ENOENT # File does not exist
    Rails.logger.warn "Announcement file not found: #{@path}"
    @opts = {}
  rescue SyntaxError => e # Syntax errors
    Rails.logger.warn "Syntax error in announcement file '#{@path}': #{e.message}. Please check the file for proper syntax."
    @opts = {}
  rescue StandardError => e # Other exceptions
    Rails.logger.warn "Error parsing announcement file '#{@path}': #{e.message}"
    @opts = {}
  end
end
