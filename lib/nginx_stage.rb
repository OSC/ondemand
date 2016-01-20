require_relative "nginx_stage/version"
require_relative "nginx_stage/configuration"
require_relative "nginx_stage/errors"
require_relative "nginx_stage/generator"
require_relative "nginx_stage/base_generator"
require_relative "nginx_stage/pun_config_generator"
require_relative "nginx_stage/app_config_generator"
require_relative "nginx_stage/nginx_process_generator"
require_relative "nginx_stage/application"

# The main namespace for NginxStage. Provides a global configuration.
module NginxStage
  # Root path of this library
  # @return [String] root path of library
  def self.root
    File.dirname __dir__
  end

  extend Configuration
end
