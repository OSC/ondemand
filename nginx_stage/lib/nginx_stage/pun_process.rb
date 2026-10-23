# frozen_string_literal: true

require 'rbconfig'

module NginxStage
  # A /proc directory descriptor refers to one process, even after PID reuse.
  # Identify the master through that descriptor and use it for signaling too.
  class PunProcess
    MAX_COMMAND_BYTES = 16_384
    MASTER_PREFIX = 'nginx: master process '
    PF_KTHREAD = 0x00200000
    WORKER_TITLES = ['nginx: worker process', 'nginx: worker process is shutting down'].freeze
    SIGNALS = { stop: 'TERM', quit: 'QUIT', reload: 'HUP', reopen: 'USR1' }.freeze
    SIGNAL_SYSCALL = 424
    SUPPORTED_CPUS = ['x86_64', 'aarch64', 'ppc64le', 'powerpc64le'].freeze

    def self.proc_available?
      RUBY_PLATFORM.include?('linux') && File.read('/proc/self/stat').split.first.to_i == Process.pid
    rescue SystemCallError, IOError
      false
    end

    def self.state(pid_file:, user:)
      return :dead unless pid_file.running_process?

      new(pid: pid_file.pid, user: user).state
    rescue SystemCallError, IOError
      :unknown
    end

    def self.signal(pid_file:, user:, signal:)
      new(pid: pid_file.pid, user: user).signal(signal)
    end

    # Probe the actual host kernel and syscall policy without delivering a signal.
    # This checks the same /proc directory descriptor API used for PUN signaling.
    def self.check_signal_support!
      unless proc_available? && SUPPORTED_CPUS.include?(RbConfig::CONFIG['host_cpu'])
        raise Error, 'Safe PUN signaling requires Linux procfs in the caller PID namespace and a supported CPU'
      end

      File.open('/proc/self', File::RDONLY) do |handle|
        Kernel.syscall(SIGNAL_SYSCALL, handle.fileno, 0, 0, 0)
      end
      true
    rescue Errno::ENOSYS, NotImplementedError
      raise Error, 'Safe PUN signaling requires kernel support for pidfd_send_signal; no signal sent'
    rescue Errno::EPERM, Errno::EACCES
      raise Error, 'PUN signaling capability check denied by permissions or syscall policy; no signal sent'
    end

    def initialize(pid:, user:)
      @pid = pid
      @user = user
    end

    def state
      return :unknown unless self.class.proc_available?

      File.open("/proc/#{@pid}", File::RDONLY) { |handle| identify(handle) }
    rescue Errno::ENOENT, Errno::ESRCH
      missing_state
    rescue SystemCallError, IOError
      :unknown
    end

    def signal(operation)
      number = Signal.list.fetch(SIGNALS.fetch(operation.to_sym))
      unless self.class.proc_available? && SUPPORTED_CPUS.include?(RbConfig::CONFIG['host_cpu'])
        raise Error, 'Safe PUN signaling requires Linux pidfd_send_signal on x86_64, aarch64 or ppc64le'
      end

      File.open("/proc/#{@pid}", File::RDONLY) do |handle|
        identity = identify(handle)
        raise Errno::ESRCH if identity == :dead
        raise Error, "Refusing to signal PUN for #{@user}: process identity is #{identity}" unless identity == :matching

        # No numeric-PID kill or nginx -s reread may follow this validation.
        Kernel.syscall(SIGNAL_SYSCALL, handle.fileno, number, 0, 0)
      end
    rescue Errno::ENOENT
      raise Errno::ESRCH if missing_state == :dead

      raise Error, "Refusing to signal PUN for #{@user}: process metadata is unavailable"
    rescue Errno::ENOSYS, NotImplementedError
      raise Error, 'Safe PUN signaling requires kernel support for pidfd_send_signal; no signal sent'
    end

    private

    def missing_state
      Process.getpgid(@pid)
      :unknown
    rescue Errno::ESRCH
      :dead
    rescue SystemCallError
      :unknown
    end

    def identify(handle)
      root = "/proc/self/fd/#{handle.fileno}"
      # Read via the open directory, never by reconstructing /proc/<numeric PID>.
      identity = stat_identity(process_stat(root))
      return identity if identity

      command = read_command(root)
      command ? classify(root, command) : :unknown
    rescue Errno::ENOENT, Errno::ESRCH
      # A zombie can have a stat entry but no executable. Recheck the same handle.
      ['Z', 'X'].include?(process_stat(root).first) ? :dead : :unknown
    rescue SystemCallError, IOError
      :unknown
    end

    def process_stat(root)
      File.read("#{root}/stat").split(') ').last.to_s.split
    end

    def stat_identity(stat)
      return :dead if ['Z', 'X'].include?(stat.first)
      return :unknown unless stat.length >= 20

      flags = Integer(stat[6], exception: false)
      return :unknown unless flags && flags >= 0

      :foreign unless (flags & PF_KTHREAD).zero?
    end

    def read_command(root)
      command = File.binread("#{root}/cmdline", MAX_COMMAND_BYTES).to_s
      return if command.empty? || command.bytesize == MAX_COMMAND_BYTES

      command.sub(/\x00+\z/, '')
    end

    def classify(root, command)
      nginx_executable = nginx_executable?(root)
      uid = File.read("#{root}/status")[/^Uid:\s+\d+\s+(\d+)/, 1]
      return :unknown unless uid

      return nginx_role(command, uid.to_i) if nginx_executable

      return :unknown if command.start_with?('nginx:')

      :foreign
    end

    def master_title(user)
      "#{MASTER_PREFIX}(#{user}) #{NginxStage.nginx_args(user: user).join(' ')}"
    end

    def nginx_role(command, uid)
      return :foreign if WORKER_TITLES.include?(command)
      return :unknown unless uid == Process.euid
      return :matching if command == master_title(@user)

      other_user = command[%r{\Anginx: master process \(([^()/\s]+)\) }, 1]
      return :foreign if other_user && other_user != @user.to_s && command == master_title(other_user)

      :unknown
    end

    def nginx_executable?(root)
      executable = File.stat("#{root}/exe")
      expected = File.stat(NginxStage.nginx_bin)
      return true if executable.dev == expected.dev && executable.ino == expected.ino
      return false unless secure_binary?(executable, expected.uid) && secure_binary?(expected, expected.uid)

      # Package replacement can unlink the running inode or retain it under a
      # known backup name in the same trusted binary directory. Never match by
      # basename or by the '(deleted)' suffix alone.
      trusted_upgrade_path?(File.readlink("#{root}/exe"), executable)
    end

    def trusted_upgrade_path?(path, executable)
      if executable.nlink.zero?
        return false unless path.end_with?(' (deleted)')

        path = path.delete_suffix(' (deleted)')
      end
      canonical = File.realpath(NginxStage.nginx_bin)
      if path == "#{canonical} (deleted)" && executable.nlink.positive?
        return trusted_dpkg_backup?(canonical, executable)
      end

      paths = [canonical, "#{canonical}.old", "#{canonical}.dpkg-tmp"]
      paths.include?(path) && (executable.nlink.zero? || path != canonical)
    end

    # dpkg hard-links the old inode before renaming the new binary over it.
    # procfs retains the deleted original dentry name while nlink is still one.
    def trusted_dpkg_backup?(canonical, executable)
      backup = File.lstat("#{canonical}.dpkg-tmp")
      secure_binary?(backup, executable.uid) && backup.dev == executable.dev && backup.ino == executable.ino
    rescue Errno::ENOENT
      false
    end

    def secure_binary?(stat, owner)
      stat.file? && stat.uid == owner && (stat.mode & 0o022).zero?
    end
  end
end
