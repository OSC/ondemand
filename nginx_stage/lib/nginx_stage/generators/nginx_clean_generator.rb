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
          if skip_nginx
            puts u if session_count(u).zero? || force
            next
          end

          NginxStage.with_pun_start_lock(user: u) do
            pid_path = PidFile.new NginxStage.pun_pid_path(user: u)
            running = pid_path.running_process?
            unless running
              remove_stale_socket(NginxStage.pun_socket_path(user: u))
              remove_path(pid_path.to_s)
              $stderr.puts "stale pid file removed: #{pid_path}"
            end
            if session_count(u).zero? || force
              stop_pun(pid_path.pid, u) if running
              puts u
            end
          end
        rescue
          $stderr.puts "#{$!.to_s}"
        end
      end

      NginxStage.inactive_users.each do |u|
        next if user && user != u

        begin
          if skip_nginx
            puts "#{u} (disabled)"
            next
          end

          NginxStage.with_pun_start_lock(user: u) do
            next if account_exists?(u)

            puts "#{u} (disabled)"
            clean_disabled_pun(u)
          end
        rescue StandardError => e
          warn "Error trying to clean up disabled user #{u}: #{e.message}"
        end
      end
    end

    private

    def account_exists?(user)
      NginxStage::User.new(user)
      true
    rescue ArgumentError
      false
    end

    def clean_disabled_pun(user)
      pid_path = NginxStage.pun_pid_path(user: user)
      socket_path = NginxStage.pun_socket_path(user: user)
      pending_path = NginxStage.pun_cleanup_path(user: user)
      pid_file = begin
        PidFile.new(pid_path)
      rescue MissingPidFile
        raise unless File.file?(pending_path)
      end

      # nginx may remove its PID as soon as it receives TERM.
      File.open(pending_path, File::WRONLY | File::CREAT | File::EXCL, 0600) {} unless File.exist?(pending_path)

      running = pid_file&.running_process?
      if running
        stop_pun(pid_file.pid, user)
      else
        remove_stale_socket(socket_path)
      end
      remove_path(NginxStage.pun_secret_key_base_path(user: user))
      remove_path(NginxStage.pun_config_path(user: user))
      remove_path(pid_path) unless running
      begin
        remove_disabled_run_directory(File.dirname(pid_path))
      rescue Errno::ENOTEMPTY => e
        warn "Error trying to clean up disabled user #{user}: #{e.message}"
      end
      remove_path(pending_path) unless File.exist?(pid_path) || File.exist?(socket_path)
    end

    def remove_disabled_run_directory(path)
      begin
        Dir.rmdir(path)
      rescue Errno::ENOTEMPTY
        sleep(0.5)
        Dir.rmdir(path)
      end
    rescue Errno::ENOENT
      nil
    end

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
        nginx_executable?(pid) && start_time == process_start_time(pid)
    rescue SystemCallError
      false
    end

    def nginx_executable?(pid)
      executable = "/proc/#{pid}/exe"
      installed = NginxStage.nginx_bin
      File.identical?(executable, installed) ||
        File.readlink(executable) == "#{File.realpath(installed)} (deleted)"
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
