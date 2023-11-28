module UserSettingStore

  def user_settings
    @user_settings = read_user_settings
    @user_settings
  end

  def update_user_settings(template_name, json_session_context)
    # Ensure @user_settings is initialized
    user_settings
    template_key = template_name.gsub(/[\x00\/\\:\*\?\"<>\| ]/, '_').to_sym
    #updated_settings = { prefill_templates: { template_key => json_session_context }}
    if user_settings[:prefill_templates][template_key].nil? 
      create_app_key(template_key, json_session_context)
    else
      context = user_settings[:prefill_templates][template_key]
      @user_settings[:prefill_templates][template_key] = json_session_context
      save_user_settings
    end
  end

  def user_prefill_templates(template_name)
    Rails.logger.debug("")
    Rails.logger.debug("UserSettingStore::template_name.class: #{template_name.class}")
    Rails.logger.debug("template_name: #{template_name}")
    Rails.logger.debug("")
    Rails.logger.debug("")
    user_settings[:prefill_templates][template_name]
  end

  private

  def create_app_key(template_key, json_session_context)
    user_settings[:prefill_templates][template_key] = json_session_context
  end

  def read_user_settings
    user_settings = {}
    return user_settings unless user_settings_path.exist?

    begin
      yml = YAML.safe_load(user_settings_path.read) || {}
      user_settings = yml.deep_symbolize_keys
    rescue => e
      Rails.logger.error("Can't read or parse settings file: #{user_settings_path} because of error #{e}")
    end

    user_settings
  end

  def save_user_settings
    # Ensure there is a directory to write the user settings file
    user_settings_path.dirname.tap { |p| p.mkpath unless p.exist? }
    File.open(user_settings_path.to_s, "w") { |file| file.write(@user_settings.deep_stringify_keys.to_yaml) }
  end

  def user_settings_path
    Pathname.new(::Configuration.dataroot).join(::Configuration.user_settings_file)
  end
end
