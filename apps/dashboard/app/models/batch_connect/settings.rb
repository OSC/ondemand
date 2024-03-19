module BatchConnect
  # An Interactive Application saved parameters from the form.
  class Settings
    include ActiveModel::Model

    class << self
      def find(token, name)
        settings_values = BatchConnectSettingsReader.new.app_templates(token).fetch(name.to_sym, {})
        BatchConnect::Settings.new(token, name, settings_values)
      end

      def app_settings(app_token)
        BatchConnectSettingsReader.new.all.fetch(app_token.to_sym, {})
      end

      def all_by_app_title
        all.group_by { |settings| settings.app.title }.sort
      end

      def all
        BatchConnectSettingsReader.new.all.flat_map do |token, settings_by_name|
          settings_by_name.map do |settings_name, settings_values|
            BatchConnect::Settings.new(token, settings_name, settings_values)
          end
        end
      end
    end

    attr_reader :token, :name, :values

    def initialize(token, name, values)
      @token = token.to_s
      @name = name.to_s
      @values = values.to_h
    end

    def app
      @app ||= BatchConnect::App.from_token token
    end

    def to_h
      values.clone
    end

    def outdated?
      outdated = false
      # CHECK IF THERE ARE NEW ATTRIBUTES NOT IN THE VALUES HASH
      app.attributes.each do |attribute|
        outdated = true unless values.key?(attribute.id.to_sym)
      end
      # CHECK IF THERE ARE OLD VALUES NO LONGER IN THE APP ATTRIBUTES STILL IN THE VALUES HASH
      values.each do |attribute_id, _|
        outdated = true if app.attributes.select { |attribute| attribute.id.to_sym == attribute_id }.empty?
      end

      outdated
    end

    def save
      BatchConnectSettingsReader.new.save_app_template(token, name, to_h)
    end

    def delete
      BatchConnectSettingsReader.new.delete_app_template(token, name)
    end

    private

    class BatchConnectSettingsReader
      include UserSettingStore

      BC_TEMPLATES = :batch_connect_templates

      def all
        user_settings[BC_TEMPLATES].to_h
      end

      def app_templates(app_token)
        all[app_token.to_sym].to_h
      end

      def save_app_template(app_token, name, key_values)
        current_templates = all
        current_app_templates = current_templates[app_token.to_sym] || {}

        new_template = {}
        new_template[name.to_sym] = key_values

        new_settings = {}
        new_settings[BC_TEMPLATES] = {}
        new_settings[BC_TEMPLATES][app_token.to_sym] = current_app_templates.merge(new_template)

        update_user_settings(new_settings)
      end

      def delete_app_template(app_token, name)
        current_templates = all
        current_templates.fetch(app_token.to_sym, {}).delete(name.to_sym)
        current_templates.delete(app_token.to_sym) if current_templates.fetch(app_token.to_sym, {}).empty?

        new_settings = {}
        new_settings[BC_TEMPLATES] = current_templates
        update_user_settings(new_settings)
      end
    end

  end
end
