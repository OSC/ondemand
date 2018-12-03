require_relative "nginx_stage/version"
require_relative "nginx_stage/configuration"
require_relative "nginx_stage/errors"
require_relative "nginx_stage/user"
require_relative "nginx_stage/pid_file"
require_relative "nginx_stage/socket_file"
require_relative "nginx_stage/secret_key_base_file"
require_relative "nginx_stage/views/pun_config_view"
require_relative "nginx_stage/views/app_config_view"
require_relative "nginx_stage/generator"
require_relative "nginx_stage/generators/pun_config_generator"
require_relative "nginx_stage/generators/app_config_generator"
require_relative "nginx_stage/generators/app_reset_generator"
require_relative "nginx_stage/generators/app_list_generator"
require_relative "nginx_stage/generators/app_clean_generator"
require_relative "nginx_stage/generators/nginx_process_generator"
require_relative "nginx_stage/generators/nginx_show_generator"
require_relative "nginx_stage/generators/nginx_list_generator"
require_relative "nginx_stage/generators/nginx_clean_generator"
require_relative "nginx_stage/application"

require 'etc'

# The main namespace for NginxStage. Provides a global configuration.
module NginxStage
  # Root path of this library
  # @return [String] root path of library
  def self.root
    File.dirname __dir__
  end

  # Path to the configuration file
  # @return [String] path to config file
  def self.config_file
    ENV["NGINX_STAGE_CONFIG_FILE"] || '/etc/ood/config/nginx_stage.yml'
  end

  extend Configuration

  # The current version of OnDemand installed
  # @example Get version of OnDemand for version file that exists
  #   ondemand_version #=> "1.3.0"
  # @example No version file exists
  #   ondemand_version #=> nil
  # @return [String, nil] current version of installed OnDemand if exists
  def self.ondemand_version
    version = File.read(ondemand_version_path).strip
    version.empty? ? nil : version
  rescue
    nil
  end

  # The unique name of the hosted OnDemand portal used to namespace apps, their
  # data, and logging information
  # @example No OnDemand Portal name specified
  #   portal #=> "ondemand"
  # @example The AweSim portal is specified
  #   portal #=> "awesim"
  # @return [String] unique portal name
  def self.portal(default: "ondemand")
    portal = ondemand_portal.to_s.strip
    if portal.empty?
      default
    else
      portal.downcase.gsub(/\s+/, "_")
    end
  end

  # The title of the hosted OnDemand portal
  # @example No title supplied
  #   title #=> "Open OnDemand"
  # @example The OSC OnDemand portal
  #   title #=> "OSC OnDemand"
  # @return [String] portal title
  def self.title(default: "Open OnDemand")
    title = ondemand_title.to_s.strip
    if title.empty?
      default
    else
      title
    end
  end


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

  # Environment used during execution of nginx binary
  # @example Start the per-user NGINX for user Bob
  #   nginx_env(user: 'bob')
  #   #=> { "USER" => "bob", ... }
  # @param user [String] the owner of the nginx process
  # @return [Hash{String=>String}] the environment used to execute the nginx process
  def self.nginx_env(user:)
    {
      "USER" => user,
      "ONDEMAND_VERSION" => ondemand_version,
      "ONDEMAND_PORTAL" => portal,
      "ONDEMAND_TITLE" => title,
      "SECRET_KEY_BASE" => SecretKeyBaseFile.new(user).secret,
      # only set these if corresponding config is set in nginx_stage.yml
      "OOD_DASHBOARD_TITLE" => title(default: nil),
      "OOD_PORTAL" => portal(default: nil)
    }.merge(pun_custom_env)
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

  # Get a hash of all the staged app configs
  # @example List of all staged app configs
  #   staged_apps
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
  def self.staged_apps
    staged_apps = {}
    @app_config_path.each do |env, path|
      staged_apps[env] = Dir[app_config_path(env: env, owner: '*', name: '*')].map do |v|
        matches = /#{app_config_path(env: env, owner: '(?<owner>.+)', name: '(?<name>.+)')}/.match(v)
        {
          owner: matches.names.include?('owner') ? matches[:owner] : nil,
          name:  matches.names.include?('name')  ? matches[:name]  : nil
        }
      end
    end
    staged_apps
  end

  # Run Ruby block as a different user if possible
  # NB: Will forego user switching if current process is not root-owned
  # @param user [String, Integer, nil] the user or user id to switch to
  # @yield [] Block to run as given user
  def self.as_user(user, &block)
    (Process.uid == 0) && user ? sudo(user, &block) : block.call
  end

  private
    # Switch user/group effective id's as well as secondary groups
    def self.sudo(user, &block)
      passwd = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)
      name, uid, gid = passwd.name, passwd.uid, passwd.gid
      Process.initgroups(name, gid)
      Process::GID.grant_privilege(gid)
      Process::UID.grant_privilege(uid)
      block.call
    ensure
      Process::UID.grant_privilege(0)
      Process::GID.grant_privilege(0)
      Process.initgroups('root', 0)
    end
end
