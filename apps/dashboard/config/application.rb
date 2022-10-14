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
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Locales are handled in config/initializers/locales.rb.

    # Custom error pages
    config.exceptions_app = self.routes

    if ::Configuration.load_external_config?
      # Ensuring OOD initializers run last so that user's cannot override what we 
      # specify unless we allow the override as well in our own initializers.
      config.paths["config/initializers"] << ::Configuration.config_root.join("initializers").to_s
      config.paths["app/views"].unshift ::Configuration.config_root.join("views").to_s
    end
  end
end
