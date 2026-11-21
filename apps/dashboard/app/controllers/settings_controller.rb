# frozen_string_literal: true

# The Controller for user level settings /dashboard/settings.
# Current supported settings: profile, announcement, safe_viewing
class SettingsController < ApplicationController
  include UserSettingStore
  ALLOWED_SETTINGS = [:profile, :safe_viewing, { announcements: {} }].freeze

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
    new_settings = user_customization_param.to_h
    alert = nil
    updated = false
    new_settings.each do |action, args|
      begin
        UserCustomization.instance.public_send(action, args)
        updated = true
      rescue StandardError => e
        alert = I18n.t('dashboard.favorites_not_updated', error: e)
      end
    end

    announcements = Hash.new
    announcements[:notice] = I18n.t('dashboard.settings_updated') if updated
    announcements[:alert] = alert if alert
    respond_to do |format|
      format.html do
        redirect_back allow_other_host: false, fallback_location: root_url, **announcements
      end

      format.json do
        if alert
          render json: { error_message: announcements[:alert] }
        else
          render json: {}
        end
      end
    end
  end

  private

  def settings_param
    params.require(:settings).permit(ALLOWED_SETTINGS) if params[:settings].present?
  end

  def user_customization_param
    params.require(:user_customization).permit(UserCustomization.supported_actions)
  end

  def back_param
    params.permit(:back)[:back]
  end

  def read_settings(params)
    return {} if params.nil?

    settings = params.to_h.deep_symbolize_keys
    if settings.key?(:safe_viewing)
      settings[:safe_viewing] = ActiveModel::Type::Boolean.new.cast(settings[:safe_viewing])
    end
    settings
  end
end
