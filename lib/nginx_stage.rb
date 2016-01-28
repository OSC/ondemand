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

  #
  # per-user NGINX helper methods
  #

  # Path to generated per-user NGINX config file
  # @example User Bob's nginx config
  #   pun_config_path(user: bob)
  #   #=> "/var/log/nginx/config/bob.conf"
  # @param user [String] the user of the nginx process
  # @return [String] the path to the per-user nginx config file
  def self.pun_config_path(user:)
    File.join pun_config_root, "#{user}.conf"
  end

  # Path to the user's personal error.log
  # @example User Bob's nginx error log
  #   error_log_path(user: bob)
  #   #=> "/var/log/nginx/bob/error.log"
  # @param user [String] the user of the nginx process
  # @return [String] the path to the nginx error log
  def self.error_log_path(user:)
    File.join pun_log_root, user, 'error.log'
  end

  # Path to the user's personal access.log
  # @example User Bob's nginx access log
  #   access_log_path(user: bob)
  #   #=> "/var/log/nginx/bob/access.log"
  # @param user [String] the user of the nginx process
  # @return [String] the path to the nginx access log
  def self.access_log_path(user:)
    File.join pun_log_root, user, 'access.log'
  end

  # Path to user's personal tmp root
  # @example User Bob's nginx tmp root
  #   tmp_root(user: bob)
  #   #=> "/var/lib/nginx/tmp/bob"
  # @param user [String] the user of the nginx process
  # @return [String] the path to the tmp root
  def self.tmp_root(user:)
    File.join pun_tmp_root, user
  end

  # Path to the user's per-user NGINX pid file
  #   /var/run/nginx/<user>/passenger.pid
  # @example User Bob's pid file
  #   pid_path(user: bob)
  #   #=> "/var/run/nginx/bob/passenger.pid"
  # @param user [String] the user of nginx process
  # @return [String] the path to the pid file
  def self.pid_path(user:)
    File.join pun_run_root, user, 'passenger.pid'
  end

  # Path to the user's per-user NGINX socket file
  # @example User Bob's socket file
  #   socket_path(user: bob)
  #   #=> "/var/run/nginx/bob/passenger.sock"
  # @param user [String] the user of nginx process
  # @return [String] the path to the socket file
  def self.socket_path(user:)
    File.join pun_run_root, user, 'passenger.sock'
  end

  #
  # NGINX app helper methods
  #

  # Path to generated NGINX app config
  # @example Dev app owned by Bob
  #   app_config_path(env: :dev, owner: bob, name: 'rails1')
  #   #=> "/var/lib/nginx/config/dev/bob/rails1.conf"
  # @example Shared app owned by Dan
  #   app_config_path(env: :dev, owner: dan, name: 'fillsim')
  #   #=> "/var/lib/nginx/config/shared/dan/fillsim.conf"
  # @param env [Symbol] environment the app is run under
  # @param owner [String] the owner of the app
  # @param name [String] the name of the app
  # @return [String] the path to the nginx app config on the local filesystem
  def self.app_config_path(env:, owner:, name:)
    File.join app_config_root, env.to_s, owner, "#{name}.conf"
  end

  # Path to the app root on the local filesystem
  # @example App root for dev app owned by Bob
  #   get_app_path(env: :dev, owner: bob, name: 'rails1')
  #   #=> "~bob/ood_dev/rails1"
  # @example App root for shared app owned by Dan
  #   get_app_path(env: :shared, owner: dan, name: 'fillsim')
  #   #=> "~dan/ood_shared/fillsim"
  # @param env [Symbol] environment the app is run under
  # @param owner [String] the owner of the app
  # @param name [String] the name of the app
  # @return [String] the path to the app root on the local filesystem
  # @raise [InvalidRequest] if the environment specified doesn't exist
  def self.get_app_root(env:, owner:, name:)
    path = app_root.fetch(env) do
      raise InvalidRequest, "invalid request environment: #{env}"
    end % {owner: owner, name: name}
    File.expand_path path
  end

  # The URI used to access the app from the browser, not including any sub-uri
  # @example URI for dev app owned by Bob
  #   get_app_request(env: :dev, owner: bob, name: 'rails1')
  #   #=> "/dev/rails1"
  # @example URI for shared app owned by Dan
  #   get_app_request(env: :dev, owner: dan, name: 'fillsim')
  #   #=> "/shared/dan/fillsim"
  # @param env [Symbol] environment the app is run under
  # @param owner [String] the owner of the app
  # @param name [String] the name of the app
  # @return [String] the URI used to access a given app
  # @raise [InvalidRequest] if the environment specified doesn't exist
  def self.get_app_request(env:, owner:, name:)
    app_request_format.fetch(env) do
      raise InvalidRequest, "invalid request environment: #{env}"
    end % {owner: owner, name: name}
  end

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

  #
  # NGINX helper methods
  #

  # Command used to execute the per-user NGINX
  # @example Start the per-user NGINX for user
  #   nginx_cmd(user: bob) #=> "/usr/bin/nginx -c /var/lib/nginx/config/bob.conf"
  # @param user [String] the owner of the nginx process
  # @param signal [Symbol] the signal sent to the nginx process
  # @return [String] the shell command used to execute the nginx process
  def self.nginx_cmd(user:, signal: nil)
    args = "-c '#{pun_config_path(user: user)}'"
    args << " -s '#{signal}'" if signal
    "#{nginx_bin} #{args}"
  end
end
