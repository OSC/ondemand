# frozen_string_literal: true

# Controller for custom pinned apps. PATCH updates user pinned app tokens;
# DELETE resets to system default by removing the user override.
class PinnedAppsController < ApplicationController
  skip_before_action :check_required_announcements

  def update
    tokens = Array(params[:pinned_app_tokens]).map(&:to_s).reject(&:blank?)
    filtered_tokens = tokens.select do |token|
      valid_pinned_app_tokens.include?(token)
    end
    update_user_settings({ PINNED_APPS_USER_SETTING_KEY => filtered_tokens })

    respond_to do |format|
      format.html do
        redirect_to root_url, notice: t('dashboard.pinned_apps_saved_notice')
      end
      format.json { head :no_content }
    end
  end

  def destroy
    clear_user_setting(PINNED_APPS_USER_SETTING_KEY)

    respond_to do |format|
      format.html do
        redirect_to root_url, notice: t('dashboard.pinned_apps_reset_notice')
      end
      format.json { head :no_content }
    end
  end

  private

  def valid_pinned_app_tokens
    @valid_pinned_app_tokens ||= dashboard_pinned_app_options.map do
      |_title, token|
      token
    end
  end

  def dashboard_pinned_app_options
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
