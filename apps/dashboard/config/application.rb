require 'uri'
require_relative 'boot'

# require "rails"

# This is not loaded in rails/all but inside active_record so add it if
# you want your models work as expected
require "active_model/railtie" 
require "active_job/railtie"
# require "active_record/railtie"  # Enable if we start using ActiveRecord

# And now the rest
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"  # Enable if we start using ActionCable (websockets)
# require "active_storage/engine"  # Enable if we start using ActiveRecord
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Locales are handled in config/initializers/locales.rb.

    # Custom error pages
    config.exceptions_app = self.routes

    if ::Configuration.load_external_config?
      # Setting system /etc initializers before OOD initializers allowing users flexibility
      # for container and POC deployments.
      config.paths["config/initializers"] << ::Configuration.config_root.join("initializers").to_s
      config.paths["app/views"].unshift ::Configuration.config_root.join("views").to_s
    end
  end
end
