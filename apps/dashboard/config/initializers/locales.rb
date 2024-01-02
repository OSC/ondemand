# frozen_string_literal: true

# Setup locales by adding to the locale path, setting the default and setting fallbacks

extra_locales = ::Configuration.locales_root.join('*.{yml,rb}')
base_locales = Rails.application.config.root.join('config', 'locales', '*.{yml,rb}')

Rails.application.config.i18n.load_path += Dir[base_locales, extra_locales]
Rails.application.config.i18n.default_locale = ::Configuration.locale
Rails.application.config.i18n.fallbacks = [:en]
