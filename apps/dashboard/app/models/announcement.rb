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

  def button_text
    opts.fetch(:button_text, I18n.t('dashboard.announcements_button_text')).to_s
  end

  # Whether this is a valid announcement
  # @return [Boolean] whether it is valid
  def valid?
    return false unless msg

    return false if dismissible? && !id

    true
  end

  def completed?
    dismissible? && user_settings.dig(:announcements, id.to_sym)
  end

  def dismissible?
    required? || opts.fetch(:dismissible, false)
  end

  def required?
    opts.fetch(:required, false)
  end

  def id
    default_id = @path.basename.to_s if @path
    # default_id = Digest::SHA1.hexdigest(@path.basename.to_s) if @path
    opts.fetch(:id, default_id)
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
  rescue Errno::ENOENT, SyntaxError # File does not exist or syntax errors
    @opts = {}
  rescue StandardError => e
    Rails.logger.warn "Error parsing announcement file '#{@path}': #{e.message}"
    @opts = {}
  end
end
