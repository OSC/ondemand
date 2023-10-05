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
    @prefill_templates = read_prefill_templates
  end

  private

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

  # TEMPLATES
  def read_prefill_templates
    prefill_templates = {}
    return prefill_templates unless user_settings_path.exist?

    begin
      prefill_templates = JSON.load(user_settings_path.read)
    rescue => err
      Rails.logger.error("Can't read or load json file: #{e}")
    end
  end

  def save_prefill_template
    user_settings_path.dirname.tap do |path|
      path.mkpath unless path.exist?
      File.open(user_settings_path.to_s, "w") do |file|
        file.write(prefill_templates)
      end
    end
  end
end
