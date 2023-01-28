# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
class SettingsController < ApplicationController
  ALLOWED_SETTINGS = [:profile].freeze

  def update
    new_settings = read_settings(settings_param)
    CurrentUser.update_user_settings(new_settings) unless new_settings.empty?

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
      params&.each { |key, value| settings[key] = value }
    end
  end
end
