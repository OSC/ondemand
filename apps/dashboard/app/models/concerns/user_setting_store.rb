module UserSettingStore

  BC_TEMPLATES = :batch_connect_templates

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

  def bc_templates(app_token)
    templates = user_settings[BC_TEMPLATES]
    return [] if templates.nil? || templates.empty?

    user_settings[BC_TEMPLATES][app_token.to_sym].to_a
  end

  # save_bc_template(@app.token, params[:template_name], @session_context.to_h)
  def save_bc_template(app_token, name, key_values)
    current_templates = user_settings[BC_TEMPLATES] || {}
    current_app_templates = current_templates[app_token.to_sym] || {}

    new_template = {}
    new_template[name.to_sym] = key_values

    new_settings = {}
    new_settings[BC_TEMPLATES] = {}
    new_settings[BC_TEMPLATES][app_token.to_sym] = current_app_templates.merge(new_template)

    update_user_settings(new_settings)
  end
end
