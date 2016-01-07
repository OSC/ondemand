module NginxStage
  class GeneratePun < Generate
    attr_reader :socket

    def initialize(opts)
      super(opts)
      @socket = opts.fetch(:socket, nil)
    end

    add_hook :require_socket do
      raise MissingOption, "missing option: --socket=SOCKET" unless socket
    end

    add_hook :validate_socket do
      raise InvalidSocket, "invalid socket: #{socket}" if File.exist?(socket)
    end

    add_hook :create_tmp_root do
      FileUtils.mkdir_p tmp_root
    end

    add_hook :create_config do
      template "pun.config.erb", File.join(NginxStage.pun_config_root, "#{user}.config")
    end

    private
      def error_log_path
        File.join NginxStage.pun_log_root, user, 'error.log'
      end

      def access_log_path
        File.join NginxStage.pun_log_root, user, 'access.log'
      end

      def tmp_root
        File.join NginxStage.pun_tmp_root, user
      end

      def pid_path
        File.join NginxStage.pun_pid_root, "#{user}.pid"
      end
  end
end
