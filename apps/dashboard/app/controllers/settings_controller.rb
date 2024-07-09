# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
class SettingsController < ApplicationController
  include UserSettingStore
  ALLOWED_SETTINGS = [:profile, { announcements: {} }].freeze

  def update
    new_settings = read_settings(settings_param)
    update_user_settings(new_settings) unless new_settings.empty?

    logger.info "settings: updated user settings to: #{new_settings}"
    respond_to do |format|
      format.html { redirect_to root_url, notice: I18n.t('dashboard.settings_updated') }
      format.json { head :no_content }
    end
  end

  private

  def settings_param
    params.require(:settings).permit(ALLOWED_SETTINGS) if params[:settings].present?
  end

  def read_settings(params)
    {}.tap do |settings|
      params&.each do |key, value|
        value = value.to_h if value.is_a?(ActionController::Parameters)
        settings[key] = value
      end
    end
  end
end
