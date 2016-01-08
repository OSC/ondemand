module NginxStage
  class GeneratePunConfig < Generate
    attr_reader :signal

    def initialize(opts)
      super(opts)
      @signal = opts.fetch(:signal, nil)
    end

    add_hook :create_tmp_root do
      FileUtils.mkdir_p tmp_root
    end

    add_hook :create_log_root do
      FileUtils.mkdir_p log_root
    end

    add_hook :create_pid_root do
      FileUtils.mkdir_p NginxStage.pun_pid_root
    end

    add_hook :create_socket_root do
      FileUtils.mkdir_p NginxStage.pun_sck_root
    end

    add_hook :secure_socket_root do
      target = NginxStage.pun_sck_root
      if Process.uid == 0
        FileUtils.chmod 0750, target
        FileUtils.chown 0, NginxStage.socket_group, target
      else
        FileUtils.chmod 0700, target
      end
    end

    add_hook :create_config do
      template "pun.conf.erb", pun_config_path
    end

    add_hook :run_nginx do
      args = ""
      args << " -c '#{pun_config_path}'"
      args << " -s '#{signal}'" if signal

      exec "#{NginxStage.nginx_bin} #{args}" unless skip_nginx
    end

    add_hook :return_pun_config_path do
      pun_config_path
    end

    private
      def pun_config_path
        File.join(NginxStage.pun_config_root, "#{user}.conf")
      end

      def log_root
        File.join NginxStage.pun_log_root, user
      end

      def error_log_path
        File.join log_root, 'error.log'
      end

      def access_log_path
        File.join log_root, 'access.log'
      end

      def tmp_root
        File.join NginxStage.pun_tmp_root, user
      end

      def pid_path
        File.join NginxStage.pun_pid_root, "#{user}.pid"
      end

      def socket_path
        File.join NginxStage.pun_sck_root, "#{user}.sock"
      end
  end
end
