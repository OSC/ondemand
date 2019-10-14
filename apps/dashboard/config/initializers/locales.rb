# load the fallbacks backend module
require "i18n/backend/fallbacks"

# clear the Railtie config to allow our config_root to have higher precedence
Rails.application.config.i18n = {}

# replace the backend to allow missing translations to default to OOD-supplied ones
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# load the local translations and any translations from config_root
I18n.load_path += Dir[Rails.application.config.root.join('config/locales/*.yml'), ::Configuration.locales_root.join('*.yml')]
