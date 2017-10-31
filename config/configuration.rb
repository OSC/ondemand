require 'pathname'
require 'dotenv'

# job composer app specific configuration
class Configuration
  class << self
    # The app's configuration root directory
    # @return [Pathname] path to configuration root
    def config_root
      Pathname.new(ENV["OOD_APP_CONFIG"] || "/etc/ood/config/apps/myjobs")
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
