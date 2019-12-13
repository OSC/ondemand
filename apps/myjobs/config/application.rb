require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'fileutils'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JobConstructor
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    if ::Configuration.load_external_config?
      config.paths["config/initializers"] << ::Configuration.custom_initializers_root.to_s
      config.paths["app/views"].unshift ::Configuration.custom_views_root.to_s
    end

    # Handle case where app database file is missing and user does not use the Dashboard to launch app
    if ::Configuration.production? && ((! ::Configuration.database_path.file?) || ::Configuration.database_path.empty?)
      require 'rake'
      FileUtils.chdir ::Configuration.dataroot.parent do
        load_tasks
        ::Configuration.production_database_path.parent.mkpath
        Rake::Task['db:setup'].invoke
        Rake::Task.clear
      end
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
