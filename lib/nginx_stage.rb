require_relative "nginx_stage/version"
require_relative "nginx_stage/configuration"
require_relative "nginx_stage/errors"
require_relative "nginx_stage/user"
require_relative "nginx_stage/pid_file"
require_relative "nginx_stage/socket_file"
require_relative "nginx_stage/views/pun_config_view"
require_relative "nginx_stage/views/app_config_view"
require_relative "nginx_stage/generator"
require_relative "nginx_stage/generators/pun_config_generator"
require_relative "nginx_stage/generators/app_config_generator"
require_relative "nginx_stage/generators/app_reset_generator"
require_relative "nginx_stage/generators/nginx_process_generator"
require_relative "nginx_stage/generators/nginx_show_generator"
require_relative "nginx_stage/generators/nginx_list_generator"
require_relative "nginx_stage/generators/nginx_clean_generator"
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
  # @example User app request with owner Bob
  #   parse_app_request(request: '/usr/bob/fillsim/containers')
  #   #=> {env: :usr, owner: 'bob', name: 'fillsim'}
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

  # List of users with nginx processes running
  # @return [Array<User>] the list of users with running nginx processes
  def self.active_users
    Dir[pun_pid_path(user: '*')].map{|v| User.new v[/#{pun_pid_path(user: '(.+)')}/, 1]}
  end

  # Get a hash of all the accessible app configs
  # @example List of all active app configs
  #   active_apps
  #   #=> {
  #         dev: [
  #           {owner: 'bob', name: 'rails1'},
  #           {owner: 'dan', name: 'fillsim'}
  #         ],
  #         usr: [
  #           {owner: 'bob', name: 'airsim'}
  #         ]
  #       }
  # @return [Hash] the hash of app environments with list of corresponding apps
  def self.active_apps
    active_apps = {}
    @app_config_path.each do |env, path|
      active_apps[env] = Dir[app_config_path(env: env, owner: '*', name: '*')].map do |v|
        matches = /#{app_config_path(env: env, owner: '(?<owner>.+)', name: '(?<name>.+)')}/.match(v)
        {
          owner: matches.names.include?('owner') ? matches[:owner] : "",
          name:  matches.names.include?('name')  ? matches[:name]  : ""
        }
      end
    end
    active_apps
  end
end
