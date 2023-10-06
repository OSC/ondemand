module UserSettingStore

  def user_settings
    @user_settings = read_user_settings if @user_settings.nil?
    @user_settings.clone
  end

  def update_user_settings(new_user_settings)
    # Ensure @user_settings is initialized
    user_settings
    @user_settings.deep_merge!(new_user_settings.deep_symbolize_keys)
    save_user_settings
  end

  def prefill_templates
    # retrieve the templates if they exist
    @prefill_templates ||= read_prefill_templates
  end

  private

  def save_all_settings(key, value)
    settings = read_all_settings
    settings[key] = value

    user_settings_path.tap do |path|
      path.mkpath unless path.exist?
    end
    File.open(user_settings_path.to_s, "w") do |file|
      file.write(settings.deep_stringify_keys.to_yaml)
    end
  end

  def save_user_settings
    save_all_settings(:user_settings, @user_settings)
  end

  def save_prefill_templates
    save_all_settings(:prefill_templates, @prefill_templates)
  end

  def read_all_settings
    return {} unless user_settings_path.exist?

    begin
      YAML.safe_load(user_settings_path.read) || {}
    rescue => err
      Rails.logger.error("Can't read or parse settings file: #{user_settings_path} because of error #{err}")
      {}
    end
  end

  def read_user_settings
    all_settings = read_all_settings
    all_settings[:user_settings] || {}
  end

  def read_prefill_templates
    all_settings = read_all_settings
    all_settings[:prefill_templates] || {}
  end

  def user_settings_path
    Pathname.new(::Configuration.dataroot).join(::Configuration.user_settings_file)
  end
end
