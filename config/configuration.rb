# dashboard app specific configuration
class Configuration
  class << self
    attr_writer :app_development_enabled
    attr_writer :app_sharing_enabled

    def app_development_enabled?
      return @app_development_enabled if defined? @app_development_enabled
      @app_development_enabled = ENV['OOD_APP_DEVELOPMENT'].present?
    end

    def app_sharing_enabled?
      return @app_sharing_enabled if defined? @app_sharing_enabled
      @app_sharing_enabled = ENV['OOD_APP_SHARING'].present?
    end
  end
end
