module UserSettingStore

  def update_user_settings(app_name, template_key, json_session_context)
    apps = find_app_templates(app_name)

    if apps
      apps[app_name] << { template_key => json_session_context}
    else
      prefill_templates_apps << { app_name => { template_key => json_session_context } }
    end

    begin
      File.write(user_settings_path, Psych.dump(user_settings))
    rescue => e
      # Log the error or handle it accordingly
      Rails.log.error("Error writing to file: #{e.message}")
    end
  end

  def user_settings
    begin
      Psych.load_file(user_settings_path)
    rescue => e
      Rails.logger.error("Cannot find user settings file at #{user_settings_path}: #{e.message}")
    end
  end

  def prefill_templates_apps(app)
    Rails.logger.debug("user settings['prefill_templates']['apps']: #{user_settings['prefill_templates']['apps']}")
    user_settings['prefill_templates'].nil? ? [] :  user_settings['prefill_templates']['apps']
  end

  private

  def find_app_templates(app_name)
    prefill_templates_apps.find { |app| app.key?(app_name) }
  end

  def user_settings_path
    Pathname.new(::Configuration.dataroot).join(::Configuration.user_settings_file)
  end
end
