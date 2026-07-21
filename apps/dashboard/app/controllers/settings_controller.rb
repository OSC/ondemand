# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
# Current supported settings: profile, announcement
class SettingsController < ApplicationController
  include UserSettingStore
  ALLOWED_SETTINGS = [:profile, { announcements: {} }].freeze

  def update
    new_settings = read_settings(settings_param)
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

  def update_user_customization
    new_settings = read_settings(user_customization_param)
    if new_settings.include?(:custom_files_favorites)
      parsed = JSON.parse(new_settings[:custom_files_favorites])
      @user_customization.update_files_favorites(parsed)
    end

    redirect_back allow_other_host: false, fallback_location: root_url, notice: I18n.t('dashboard.settings_updated')
  end

  private

  def settings_param
    params.require(:settings).permit(ALLOWED_SETTINGS) if params[:settings].present?
  end

  def user_customization_param
    params.require(:user_customization).permit([:custom_files_favorites])
  end

  def back_param
    params.permit(:back)[:back]
  end

  def read_settings(params)
    params.to_h
  end
end
