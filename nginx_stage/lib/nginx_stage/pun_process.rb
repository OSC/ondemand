# frozen_string_literal: true

require 'rbconfig'

module NginxStage
  # A /proc directory descriptor refers to one process, even after PID reuse.
  # Identify the master through that descriptor and use it for signaling too.
  class PunProcess
    MAX_COMMAND_BYTES = 16_384
    MASTER_PREFIX = 'nginx: master process '
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
      stat = process_stat(root)
      return :dead if ['Z', 'X'].include?(stat.first)
      return :unknown unless stat.length >= 20

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

    def read_command(root)
      command = File.binread("#{root}/cmdline", MAX_COMMAND_BYTES).to_s
      return if command.empty? || command.bytesize == MAX_COMMAND_BYTES

      command.sub(/\x00+\z/, '')
    end

    def classify(root, command)
      nginx_executable = nginx_executable?(root)
      title = "#{MASTER_PREFIX}(#{@user}) #{NginxStage.nginx_args(user: @user).join(' ')}"
      uid = File.read("#{root}/status")[/^Uid:\s+\d+\s+(\d+)/, 1]
      return :unknown unless uid

      return :matching if nginx_executable && command == title && uid.to_i == Process.euid

      # An upgraded/deleted nginx binary or unexpected nginx title is ambiguous.
      return :unknown if nginx_executable || command.start_with?('nginx:')

      :foreign
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
      paths = [canonical, "#{canonical}.old", "#{canonical}.dpkg-tmp"]
      paths.include?(path) && (executable.nlink.zero? || path != canonical)
    end

    def secure_binary?(stat, owner)
      stat.file? && stat.uid == owner && (stat.mode & 0o022).zero?
    end
  end
end
