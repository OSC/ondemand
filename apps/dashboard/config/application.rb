require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dashboard
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.0)

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.autoload_paths << Rails.root.join('lib')

    # Locales are handled in config/initializers/locales.rb.

    # Custom error pages
    config.exceptions_app = self.routes

    if ::Configuration.load_external_config?
      # Ensuring OOD initializers run last so that user's cannot override what we 
      # specify unless we allow the override as well in our own initializers.
      config.paths["config/initializers"] << ::Configuration.config_root.join("initializers").to_s
      config.autoload_paths << ::Configuration.config_root.join("lib").to_s
      config.paths["app/views"].unshift ::Configuration.config_root.join("views").to_s
    end

    # Determine if this path is safe to load. I.e., are all the files root owned.
    def safe_load_path?(path)
      path.exist? && path.children.all? { |f| File.stat(f).uid.zero? }
    end

    # Enable installed plugins only if configured by administrator
    plugins_dir = Pathname.new(::Configuration.plugins_directory)
    if plugins_dir.directory?
      plugins_dir.children.select(&:directory?).each do |installed_plugin|
        next unless installed_plugin.readable?

        initers = installed_plugin.join('initializers')
        lib = installed_plugin.join('lib')
        views = installed_plugin.join('views')

        production = ::Configuration.rails_env_production?

        # only load paths in production if every single file in the directory is root owned.
        safe_load_initers = production ? safe_load_path?(initers) : true
        safe_load_lib = production ? safe_load_path?(lib) : true
        safe_load_views = production ? safe_load_path?(views) : true

        config.paths['config/initializers'] << initers.to_s if safe_load_initers
        config.autoload_paths << lib.to_s if safe_load_lib
        config.paths["app/views"].unshift(views.to_s) if safe_load_views
      end
    end
  end
end
