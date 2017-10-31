require 'pathname'

# job composer app specific configuration
class Configuration
  extend ConfigRoot

  class << self
    # TODO: add domain specific configuration methods here
  end
end

# support custom initializers and views in /etc
Rails.application.configure do |config|
  config.paths["config/initializers"] << Configuration.config_root.join("config", "initializers").to_s
  config.paths["app/views"].unshift Configuration.config_root.join("app", "views").to_s
end
