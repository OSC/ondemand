require 'socket'

module NginxStage
  # This generator cleans all running per-user NGINX processes that are
  # inactive (i.e., not active connections).
  class NginxCleanGenerator < Generator

    include NginxStage::SessionFinder

    desc 'Clean all user running PUNs with no active connections'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To clean up any running per-user nginx process with no active
        connections:

            nginx_stage nginx_clean

        this displays the users who had their PUNs shutdown.

        To clean up ALL running per-user nginx processes whether it has an
        active connection or not:

            nginx_stage nginx_clean --force

        this also displays the users who had their PUNs shutdown.

        To clean up ALL running per-user nginx processes belonging to a specific user
        whether it has an active connection or not:

            nginx_stage nginx_clean --force --user exampleuser

        this also displays the users who had their PUNs shutdown.

        To ONLY display the users with inactive PUNs:

            nginx_stage nginx_clean --skip-nginx

        this won't terminate their per-user nginx process.
    EOF

    # Whether we forcefully kill all PUNs even if they have connections
    add_option :force do
      {
        opt_args: ["-f", "--[no-]force", "# Force clean ALL per-user nginx processes", "# Default: false"],
        default: false
      }
    end

    add_option :user do
      {
        opt_args: ["-u", "--user=USER", "# Operate on specific user", "# Default: nil (all users)"],
        default: nil,
      }
    end

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Find users with PUNs that have no active sessions and kill the process
    add_hook :delete_puns_of_users_with_no_sessions do
      NginxStage.active_users.each do |u|
        begin
          next if (user && user != u.to_s)
          pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
          running = !skip_nginx && pid_path.running_process?
          sessions = session_count(u)
          if !skip_nginx && !running
            remove_stale_socket(NginxStage.pun_socket_path(user: u))
            remove_path(pid_path.to_s)
            $stderr.puts "stale pid file removed: #{pid_path}"
          end
          if sessions.zero? || force
            stop_pun(pid_path.pid, u) if running
            puts u
          end
        rescue
          $stderr.puts "#{$!.to_s}"
        end
      end

      pid_parent_dirs_to_remove_later = []
      NginxStage.inactive_users.each do |u|
        next if user && user != u
        begin
          puts "#{u} (disabled)"
          next if skip_nginx
          pid_path = PidFile.new NginxStage.pun_pid_path(user: u)

          running = pid_path.running_process?
          if running
            stop_pun(pid_path.pid, u)
          else
            remove_stale_socket(NginxStage.pun_socket_path(user: u))
          end
          remove_path(NginxStage.pun_secret_key_base_path(user: u))
          remove_path(NginxStage.pun_config_path(user: u))
          # Keep the PID file discoverable until cleanup can finish.
          remove_path(pid_path.to_s) unless running
          pid_path_parent_dir = Pathname.new(pid_path.to_s).parent
          pid_parent_dirs_to_remove_later.push(pid_path_parent_dir)
        rescue StandardError => e
          warn "Error trying to clean up disabled user #{u}: #{e.message}"
        end
      end

      # Remove the PID path parent directories now that the nginx processes have
      # had time to clean up their Passenger PID file and socket.
      pid_parent_dirs_to_remove_later.each do |dir|
        begin
          begin
            FileUtils.rmdir(dir)
          rescue Errno::ENOTEMPTY
            # Wait for a short time, while Nginx cleans up its PID file.
            sleep(0.5)
            # Then try again once.
            FileUtils.rmdir(dir)
          end
        rescue StandardError => e
          warn "Error trying to clean up the PID file directory '#{dir}' of disabled user: #{e.message}"
        end
      end
    end

    private

    def stop_pun(pid, user)
      unless pid.positive? && pun_master?(pid, NginxStage.pun_config_path(user: user))
        raise Error, "refusing to signal unverified PUN process #{pid} for #{user}"
      end

      # TERM is nginx -s stop. Signal the verified PID directly so nginx does
      # not reread the PID file or try to load a disabled user's config.
      Process.kill('TERM', pid)
    end

    def pun_master?(pid, config_path)
      start_time = process_start_time(pid)
      title = File.binread("/proc/#{pid}/cmdline").split("\0", 2).first.to_s
      start_time && title.start_with?('nginx: master process ') && title.end_with?(" -c #{config_path}") &&
        File.identical?("/proc/#{pid}/exe", NginxStage.nginx_bin) && start_time == process_start_time(pid)
    rescue SystemCallError
      false
    end

    def process_start_time(pid)
      # Fields after the final ') ' start with field 3; starttime is field 22.
      File.binread("/proc/#{pid}/stat").rpartition(') ').last.split[19]
    end

    def remove_stale_socket(path)
      original = File.lstat(path)
      raise Error, "refusing to remove non-socket PUN path #{path}" unless original.socket?

      socket = Socket.new(:UNIX, :STREAM)
      begin
        socket.connect_nonblock(Socket.sockaddr_un(path))
      rescue Errno::ECONNREFUSED
        current = File.lstat(path)
        unless current.dev == original.dev && current.ino == original.ino
          raise Error, "PUN socket changed during cleanup: #{path}"
        end

        return remove_path(path)
      end

      raise Error, "refusing to remove live PUN socket #{path}"
    rescue Errno::ENOENT
      nil
    ensure
      socket&.close
    end

    def remove_path(path)
      File.delete(path)
    rescue Errno::ENOENT
      nil
    end
  end
end
