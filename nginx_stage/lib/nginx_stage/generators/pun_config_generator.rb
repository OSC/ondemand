require 'securerandom'
require 'syslog/logger'

module NginxStage
  # This generator stages and generates the per-user NGINX environment.
  class PunConfigGenerator < Generator
    desc 'Generate a new per-user nginx config and process'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To generate a per-user nginx environment & launch nginx:

            nginx_stage pun --user=bob --app-init-url='http://www.ood.com/nginx/init?redir=$http_x_forwarded_escaped_uri'

        this will add a URI redirect if the user accesses an app that doesn't exist.

        To generate ONLY the per-user nginx environment:

            nginx_stage pun --user=bob --skip-nginx

        this will return the per-user nginx config path and won't run nginx. In addition
        it will remove the URI redirect from the config unless we specify `--app-init-url`.
    EOF

    include PunConfigView

    # Accepts `user` as an option and validates user
    add_user_support

    # Block starting up PUNs for users with disabled shells
    add_hook :block_user_with_disabled_shell do
      raise InvalidUser, NginxStage.disabled_shell_message % user if user.shell == NginxStage.disabled_shell
    end

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # @!method app_init_url
    #   The app initialization URL the user is redirected to if can't find the
    #   app in the per-user NGINX config
    #   @return [String] app init redirect url
    add_option :app_init_url do
      {
        opt_args: ["-a", "--app-init-url=APP_INIT_URL", "# The user is redirected to the APP_INIT_URL if app doesn't exist"],
        default: nil,
        before_init: -> (uri) do
          raise InvalidAppInitUri, "invalid app-init-url syntax: #{uri}" if uri =~ /[^-\w\/?$=&.:]/
          uri
        end
      }
    end

    # @!method pre_hook_root_cmd
    #   The command to execute as root before starting the PUN
    #
    #   @return [String] the command
    add_option :pre_hook_root_cmd do
      {
        opt_args: ["-P", "--pre-hook-root=ROOT_HOOK", "# Run ROOT_HOOK as root before the PUN starts"],
        default: nil,
        before_init: -> (hook) do
          hook
        end
      }
    end

    # Create the user's personal per-user NGINX `/tmp` location for the various
    # nginx cache directories
    add_hook :create_user_tmp_root do
      empty_directory tmp_root
    end

    # Create the user's personal per-user NGINX `/log` location for the various
    # nginx log files (e.g., 'error.log' & 'access.log')
    add_hook :create_user_log_roots do
      empty_directory File.dirname(error_log_path)
      empty_directory File.dirname(access_log_path)
    end

    # Create per-user NGINX pid root
    add_hook :create_pid_root do
      empty_directory File.dirname(pid_path)
    end

    # Create and secure the nginx socket root. The socket file needs to be only
    # accessible by the reverse proxy user.
    add_hook :create_and_secure_socket_root do
      socket_root = File.dirname(socket_path)
      empty_directory socket_root
      FileUtils.chmod 0700, socket_root
      FileUtils.chown NginxStage.proxy_user, nil, socket_root if Process.uid == 0
    end

    # Generate per user secret_key_base file if it doesn't already exist
    add_hook :create_secret_key_base do
      begin
        secret = SecretKeyBaseFile.new(user)
        secret.generate unless secret.exist?
      rescue => e
        $stderr.puts "Failed to write secret to path: #{secret.path}"
        $stderr.puts e.message
        $stderr.puts e.backtrace

        abort
      end
    end

    # Run the pre hook command. This eats the output and doesn't affect
    # the overall status of the PUN startup
    # This must come before anything that cleans the process environment
    add_hook :exec_pre_hook do
      unless pre_hook_root_cmd.nil?
        args = ["--user", user.to_s]
        log = Syslog::Logger.new 'ood_nginx_stage'

        begin
          _, err, s = Open3.capture3(pre_hook_root_cmd, *args)
          log.error "#{pre_hook_root_cmd} exited with #{s.exitstatus} for user #{user}. stderr was '#{err}'" unless s.success?
        rescue StandardError => e
          log.error "#{pre_hook_root_cmd} threw exception '#{e.message}' for #{user}"
        end
      end
    end

    # Generate the per-user NGINX config from the 'pun.conf.erb' template
    add_hook :create_config do
      template "pun.conf.erb", config_path
    end

    # Run the per-user NGINX process (exit quietly on success)
    add_hook :exec_nginx do
      if !skip_nginx
        NginxStage.clean_nginx_env(user: user)
        o, s = Open3.capture2e(
          [
            NginxStage.nginx_bin,
            "(#{user})"
          ],
          *NginxStage.nginx_args(user: user)
        )
        s.success? ? exit : abort(o)
      end
    end

    # If skip nginx, then output path to the generated per-user NGINX config
    add_hook :output_pun_config_path do
      puts config_path
    end


    private
      # per-user NGINX config path
      def config_path
        NginxStage.pun_config_path(user: user)
      end
  end
end
