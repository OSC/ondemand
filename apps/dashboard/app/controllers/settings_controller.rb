# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
# Current supported settings: profile, announcement
class SettingsController < ApplicationController
  include UserSettingStore
  ALLOWED_SETTINGS = [:profile, :announcement].freeze

  def update
    new_settings = read_settings(settings_param)
    if new_settings.empty?
      respond_to do |format|
        format.html { redirect_to root_url, alert: I18n.t('dashboard.settings_invalid_request') }
        format.json { head :bad_request }
      end

      return
    end

    # Only ALLOWED_SETTINGS methods will be called
    setting, value = new_settings.first
    send("update_#{setting}", value)
  end

  def update_profile(profile)
    profile_settings = { profile: profile }
    update_user_settings(profile_settings)

    logger.info "settings: updated user settings for profile to: #{profile_settings}"
    respond_to do |format|
      format.html { redirect_to root_url, notice: I18n.t('dashboard.settings_profile_updated') }
      format.json { head :no_content }
    end
  end

  def update_announcement(announcement_id)
    announcements_settings = { announcements: { announcement_id => Time.now.localtime.strftime('%Y-%m-%d %H:%M:%S') } }
    update_user_settings(announcements_settings) unless announcement_id.empty?

    logger.info "settings: set announcement to completed: #{announcements_settings}"
    respond_to do |format|
      format.html { redirect_to root_url, notice: I18n.t('dashboard.settings_announcements_updated') }
      format.json { head :no_content }
    end
  end

  private

  def settings_param
    params.require(:settings).permit(ALLOWED_SETTINGS) if params[:settings].present?
  end

  def read_settings(params)
    {}.tap do |settings|
      params&.each { |key, value| settings[key] = value }
    end
  end
end
