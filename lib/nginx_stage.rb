require_relative "nginx_stage/version"
require_relative "nginx_stage/configuration"
require_relative "nginx_stage/errors"
require_relative "nginx_stage/user"
require_relative "nginx_stage/generator"
require_relative "nginx_stage/generators/pun_config_generator"
require_relative "nginx_stage/generators/app_config_generator"
require_relative "nginx_stage/generators/nginx_process_generator"
require_relative "nginx_stage/application"

# The main namespace for NginxStage. Provides a global configuration.
module NginxStage
  # Root path of this library
  # @return [String] root path of library
  def self.root
    File.dirname __dir__
  end

  extend Configuration

  # Regex used to parse an app request
  # @example Dev app request
  #   parse_app_request(request: '/dev/rails1/structure/1')
  #   #=> {env: :dev, name: 'rails1'}
  # @example Shared app request with owner Bob
  #   parse_app_request(request: '/shared/bob/fillsim/containers')
  #   #=> {env: :shared, owner: 'bob', name: 'fillsim'}
  # @param request [String] the URI request used to access app
  # @return [Hash] hash containing parsed information
  # @raise [InvalidRequest] if the environment specified doesn't exist
  def self.parse_app_request(request:)
    app_info = {}
    app_request_regex.each do |env, regex|
      if matches = regex.match(request)
        app_info[:env] = env
        matches.names.each { |k| app_info[k.to_sym] = matches[k] }
        break
      end
    end
    raise InvalidRequest, "invalid request: #{request}" if app_info.empty?
    app_info
  end

  # Arguments used during execution of nginx binary
  # @example Start the per-user NGINX for user Bob
  #   nginx_args(user: 'bob')
  #   #=> ['-c', '/var/lib/nginx/config/puns/bob.conf']
  # @example Stop the per-user NGINX for user Bob
  #   nginx_args(user: 'bob', signal: :stop)
  #   #=> ['-c', '/var/lib/nginx/config/puns/bob.conf', '-s', 'stop']
  # @param user [String] the owner of the nginx process
  # @param signal [Symbol] the signal sent to the nginx process
  # @return [Array<String>] the shell arguments used to execute the nginx process
  def self.nginx_args(user:, signal: nil)
    args = ['-c', pun_config_path(user: user)]
    args.push('-s', signal.to_s) if signal
    args
  end
end
