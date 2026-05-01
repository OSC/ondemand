# frozen_string_literal: true

# Controller for custom pinned apps. PATCH updates user pinned app tokens;
# DELETE resets to system default by removing the user override.
class PinnedAppsController < ApplicationController
  include UserSettingStore

  def update
    tokens = Array(params[:pinned_app_tokens]).map(&:to_s).reject(&:blank?)
    filtered_tokens = tokens.select { |token| valid_pinned_app_tokens.include?(token) }
    update_user_settings({ PINNED_APPS_USER_SETTING_KEY => filtered_tokens })

    respond_to do |format|
      format.html { redirect_to root_url, notice: t('dashboard.pinned_apps_saved_notice') }
      format.json { head :no_content }
    end
  end

  def destroy
    clear_user_setting(PINNED_APPS_USER_SETTING_KEY)

    respond_to do |format|
      format.html { redirect_to root_url, notice: t('dashboard.pinned_apps_reset_notice') }
      format.json { head :no_content }
    end
  end

end
