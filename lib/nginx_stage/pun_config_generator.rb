module NginxStage
  class PunConfigGenerator < BaseGenerator
    # The signal to send to the per-user NGINX process
    # @return [String] nginx signal
    attr_reader :signal

    # @param opts [Hash] various options for controlling the hehavior of the generator
    # @option opts [String] :user (nil) the user of the per-user nginx
    # @option opts [Boolean] :skip_nginx (false) whether to skip calling nginx binary
    # @option opts [String] :signal (nil) the signal to send nginx
    # @see BaseGenerator#initialize
    def initialize(opts)
      super(opts)
      @signal = opts.fetch(:signal, nil)
    end

    #
    # -- Invoke methods --
    #
    # These methods are invoked in the order they are defined. These methods
    # will be called before any other inherited class callback methods.
    #
    # These methods will be called after the BaseGenerator callbacks.
    #

    # Create the user's personal per-user NGINX /tmp location for the various
    # nginx cache directories
    #   /var/lib/nginx/tmp/<user>/
    add_hook :create_user_tmp_root do
      FileUtils.mkdir_p tmp_root, mode: 0755
    end

    # Create the user's personal per-user NGINX /log location for the various
    # nginx log files (e.g., 'error.log' & 'access.log')
    #   /var/log/nginx/<user>/
    add_hook :create_user_log_root do
      FileUtils.mkdir_p log_root, mode: 0755
    end

    # Create per-user NGINX /run root location that store the various user /run
    # locations
    #   /var/run/nginx/
    add_hook :create_pun_run_root do
      FileUtils.mkdir_p NginxStage.pun_run_root, mode: 0755
    end

    # Create the user's personal per-user NGINX /run location and set proper
    # permissions if directory doesn't exist. This directory will store the pid
    # and socket file. The socket file needs to be only accessible by the
    # reverse proxy daemon user.
    #   /var/run/nginx/<user>     # drwx------   apache  root
    # If the directory already exists, don't change the permisisons.
    add_hook :create_user_run_root do
      begin
        FileUtils.mkdir run_root, mode: 0700
        FileUtils.chown NginxStage.proxy_user, nil, run_root if Process.uid == 0
      rescue Errno::EEXIST
      end
    end

    # Create the per-user NGINX config from the 'pun.conf.erb' template
    add_hook :create_config do
      template "pun.conf.erb", pun_config_path
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    # if we don't :skip_nginx
    add_hook :run_nginx do
      args = ""
      args << " -c '#{pun_config_path}'"
      args << " -s '#{signal}'" if signal

      exec "#{NginxStage.nginx_bin} #{args}" unless skip_nginx
    end

    # If we skip nginx, then return the path to the generated per-user NGINX
    # config
    add_hook :return_pun_config_path do
      pun_config_path
    end

    private
      # Path to generated per-user NGINX config file
      #   /var/lib/nginx/config/<user>.conf
      def pun_config_path
        File.join(NginxStage.pun_config_root, "#{user}.conf")
      end

      # Path to user's personal log root
      #   /var/log/nginx/<user>/
      def log_root
        File.join NginxStage.pun_log_root, user
      end

      # Path to the user's personal error.log
      #   /var/log/nginx/<user>/error.log
      def error_log_path
        File.join log_root, 'error.log'
      end

      # Path to the user's personal access.log
      #   /var/log/nginx/<user>/access.log
      def access_log_path
        File.join log_root, 'access.log'
      end

      # Path to user's personal tmp root
      #   /var/lib/nginx/tmp/<user>/
      def tmp_root
        File.join NginxStage.pun_tmp_root, user
      end

      # Path to user's personal run root
      #   /var/run/nginx/<user>/
      def run_root
        File.join NginxStage.pun_run_root, user
      end

      # Path to the user's per-user NGINX pid file
      #   /var/run/nginx/<user>/passenger.pid
      def pid_path
        File.join run_root, 'passenger.pid'
      end

      # Path to the user's per-user NGINX socket file
      #   /var/run/nginx/<user>/passenger.sock
      def socket_path
        File.join run_root, 'passenger.sock'
      end
  end
end
