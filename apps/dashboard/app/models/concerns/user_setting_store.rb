# frozen_string_literal: true

module UserSettingStore
  include EncryptedCache

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
    rescue StandardError => e
      Rails.logger.error("Can't read or parse settings file: #{user_settings_path} because of error #{e}")
    end

    user_settings
  end

  def save_user_settings
    # Ensure there is a directory to write the user settings file
    user_settings_path.dirname.tap { |p| p.mkpath unless p.exist? }
    File.open(user_settings_path.to_s, 'w') { |file| file.write(@user_settings.deep_stringify_keys.to_yaml) }
  end

  def user_settings_path
    Pathname.new(::Configuration.user_settings_file)
  end

  def all_bc_templates
    user_settings[BC_TEMPLATES].to_h
  end

  def bc_templates(app)
    templates = all_bc_templates
    return {} if templates.empty?

    data = user_settings[BC_TEMPLATES][app.token.to_sym].to_h
    {}.tap do |decrypted|
      data.each do |template_name, template_values|
        decrypted[template_name.to_sym] = decypted_cache_data(app: app, data: template_values)
      end
    end
  end

  def save_bc_template(app, name, key_values)
    current_templates = user_settings[BC_TEMPLATES] || {}
    current_app_templates = current_templates[app.token.to_sym] || {}

    new_template = {}
    new_template[name.to_sym] = encypted_cache_data(app: app, data: key_values)

    new_settings = {}
    new_settings[BC_TEMPLATES] = {}
    new_settings[BC_TEMPLATES][app.token.to_sym] = current_app_templates.merge(new_template)

    update_user_settings(new_settings)
  end

  def delete_bc_template(app_token, name)
    current_templates = all_bc_templates
    current_templates.fetch(app_token.to_sym, {}).delete(name.to_sym)
    # Delete app_token group when empty
    current_templates.delete(app_token.to_sym) if current_templates.fetch(app_token.to_sym, {}).empty?

    new_settings = {}
    new_settings[BC_TEMPLATES] = current_templates
    update_user_settings(new_settings)
  end
end
