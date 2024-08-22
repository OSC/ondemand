# Utility methods related to saved_settings
module BatchConnect::SettingsHelper
  include UserSettingStore

  def all_saved_settings
    all_bc_templates.sort.flat_map do |app_token, app_saved_settings|
      app_saved_settings.sort.map do |settings_name, settings_values|
        BatchConnect::Settings.new(app_token, settings_name, settings_values)
      end
    end
  end

end
