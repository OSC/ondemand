# frozen_string_literal: true

# Controller for custom pinned apps. PATCH updates user pinned app tokens;
# DELETE resets to system default by removing the user override.
class PinnedAppsController < ApplicationController
  include UserSettingStore

  def update
    tokens = Array(params[:pinned_app_tokens]).map(&:to_s).reject(&:blank?)
    filtered_tokens = tokens.select { |token| valid_pinned_app_tokens.include?(token) }
    update_user_settings({ custom_pinned_apps: filtered_tokens })

    respond_to do |format|
      format.html { redirect_to root_url, notice: t('dashboard.pinned_apps_saved_notice') }
      format.json { head :no_content }
    end
  end

  def destroy
    clear_user_setting(:custom_pinned_apps)

    respond_to do |format|
      format.html { redirect_to root_url, notice: t('dashboard.pinned_apps_reset_notice') }
      format.json { head :no_content }
    end
  end

  private

  def valid_pinned_app_tokens
    build_pinned_app_options.map { |_title, token| token }
  end

  def build_pinned_app_options
    nav_all_apps.each_with_object([]) do |app, options|
      if app.has_sub_apps?
        app.sub_app_list.select(&:valid?).each do |sub_app|
          options << [sub_app.title, sub_app.token]
        end
      else
        options << [app.title, app.token]
      end
    end
  end
end
