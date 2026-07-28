# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = current_user_locale
  rescue I18n::InvalidLocale => e
    logger.warn "I18n::InvalidLocale #{current_user_locale}: #{e.message}"
    I18n.locale = I18n.default_locale
  end

  private

  # Resolve the locale for the current request.
  # Precedence: the user's saved preference (shared with the dashboard app
  # via ~/.config/ondemand/settings.yml, when it is a supported locale) >
  # the admin default (::Configuration.locale) > the I18n default.
  def current_user_locale
    @current_user_locale ||= begin
      candidate = nil
      path = Pathname.new(::Configuration.user_settings_file)
      if path.exist?
        yml = YAML.safe_load(path.read)
        value = yml.is_a?(Hash) ? yml.deep_symbolize_keys[:locale] : nil
        candidate = value.to_sym if value.present? && supported_locales.include?(value.to_sym)
      end
      candidate || ::Configuration.locale
    end
  end

  # The locales that users are allowed to choose from, derived from the
  # admin-configured OOD_SUPPORTED_LOCALES (colon-separated paths to locale
  # files, defaulting to just the default locale). Mirrors the dashboard's
  # ApplicationController#supported_locales.
  def supported_locales
    @supported_locales ||=
      ::Configuration.supported_locales.to_s.split(':')
      .map { |p| File.basename(p, '.*').to_sym }
      .uniq.sort
  end
end
