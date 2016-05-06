module NginxStage
  # This generator cleans all running per-user NGINX processes that are
  # inactive (i.e., not active connections).
  class NginxCleanGenerator < Generator
    desc 'Clean all user running PUNs with no active connections'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To clean up any running per-user nginx process with no active
        connections:

            nginx_stage nginx_clean

        this displays the users who had their PUNs shutdown.

        To ONLY display the users with inactive PUNs:

            nginx_stage nginx_clean --skip-nginx

        this won't terminate their per-user nginx process.
    EOF

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Find users with PUNs that have no active sessions
    add_hook :find_users_with_no_sessions do
      @users = []
      NginxStage.active_users.each do |u|
        begin
          pid_path = PidFile.new    NginxStage.pun_pid_path(user: u)
          raise StalePidFile, "stale pid file: #{pid_path}" unless pid_path.running_process?
          socket   = SocketFile.new NginxStage.pun_socket_path(user: u)
          @users << u if socket.sessions == 0
        rescue
          $stderr.puts "#{$!.to_s}"
        end
      end
    end

    # Kill the per-user NGINX processes (unless skipped)
    add_hook :kill_nginx_pids do
      @users.each do |u|
        puts u
        if !skip_nginx
          o, s = Open3.capture2e(NginxStage.nginx_bin, *NginxStage.nginx_args(user: u, signal: :stop))
          $stderr.puts o unless s.success?
        end
      end
    end
  end
end
