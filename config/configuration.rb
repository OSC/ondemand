require 'pathname'
require 'dotenv'

# dashboard app specific configuration
class Configuration
  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    # FIXME: temporary
    attr_accessor :app_sharing_facls_enabled
    alias_method :app_sharing_facls_enabled?, :app_sharing_facls_enabled

    def app_development_enabled?
      return @app_development_enabled if defined? @app_development_enabled
      ENV['OOD_APP_DEVELOPMENT'].present? || (defined?(DevRouter) && DevRouter.base_path.exist?)
    end
    alias_method :app_development_enabled, :app_development_enabled?

    def app_sharing_enabled?
      return @app_sharing_enabled if defined? @app_sharing_enabled
      @app_sharing_enabled = ENV['OOD_APP_SHARING'].present?
    end
    alias_method :app_sharing_enabled, :app_sharing_enabled?

    # The app's configuration root directory
    # @return [Pathname] path to configuration root
    def config_root
      Pathname.new(ENV["OOD_APP_CONFIG"] || "/etc/ood/config/apps/dashboard")
    end

    def custom_brand_bg_color
      return @custom_brand_bg_color if defined? @custom_brand_bg_color
      @custom_brand_bg_color = ENV.values_at('OOD_BRAND_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_BG', 'BOOTSTRAP_NAVBAR_INVERSE_BG').compact.first
    end

    def custom_brand_link_active_bg_color
      return @custom_brand_link_active_bg_color if defined? @custom_brand_link_active_bg_color
      @custom_brand_link_active_bg_color = ENV.values_at('OOD_BRAND_LINK_ACTIVE_BG_COLOR', 'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG','BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' ).compact.first
    end

    def app_root
      Pathname.new(File.expand_path("../../",  __FILE__))
    end

    def load_dotenv_files
      Dir.chdir app_root do
        # .env.local first, so it can override OOD_APP_CONFIG
        Dotenv.load(*dotenv_local_files) unless dotenv_local_files.empty?

        # load the rest of the dotenv files
        Dotenv.load(*dotenv_files)
      end
    end

    def rails_env
      (defined?(Rails) && Rails.env) || ENV['RAILS_ENV']
    end

    def dotenv_local_files
      [
        (app_root.join(".env.#{rails_env}.local") unless rails_env.nil?),
        (app_root.join(".env.local") unless rails_env == "test"),
      ].compact
    end

    def dotenv_files
      [
        config_root.join("env"),
        (app_root.join(".env.#{rails_env}") unless rails_env.nil?),
        app_root.join(".env")
      ].compact
    end
  end
end

Configuration.load_dotenv_files

# support custom initializers and views in /etc
if defined?(Rails) && defined?(Rails.application)
  Rails.application.configure do |config|
    config.paths["config/initializers"].unshift Configuration.config_root.join("config", "initializers").to_s
    config.paths["app/views"].unshift Configuration.config_root.join("app", "views").to_s
  end
end
