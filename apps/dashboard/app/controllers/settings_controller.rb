# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
# Current supported settings: profile, announcement
class SettingsController < ApplicationController
  include UserSettingStore
  ALLOWED_SETTINGS = [:profile, :locale, { announcements: {} }].freeze

  def update
    new_settings = read_settings(settings_param)
    new_settings = sanitize_locale(new_settings)
    update_user_settings(new_settings) unless new_settings.empty?

    logger.info "settings: updated user settings to: #{new_settings}"
    respond_to do |format|
      format.html do
        if back_param == 'true'
          redirect_back allow_other_host: false, fallback_location: root_url, notice: I18n.t('dashboard.settings_updated')
        else
          redirect_to root_url, notice: I18n.t('dashboard.settings_updated')
        end
      end
      format.json { head :no_content }
    end
  end

  private

  def settings_param
    params.require(:settings).permit(ALLOWED_SETTINGS) if params[:settings].present?
  end

  def back_param
    params.permit(:back)[:back]
  end

  def read_settings(params)
    params.to_h
  end

  # Only persist a locale that is actually available, to avoid users
  # storing an arbitrary (or stale) value that would raise I18n::InvalidLocale.
  def sanitize_locale(settings)
    return settings unless settings.key?(:locale)

    locale = settings[:locale]
    settings.delete(:locale) unless locale.present? && supported_locales.include?(locale.to_sym)
    settings
  end
end
