require 'erb'
require 'fileutils'
require 'open3'

require_relative "generator_helpers"

module NginxStage
  # Base class for objects that add new sub-commands to NginxStage. {Generator}
  # is basically a class with helper methods and the ability to invoke all
  # callback methods in a sequence.
  class Generator
    PUN_SHUTDOWN_TIMEOUT = 30
    PUN_SHUTDOWN_POLL_INTERVAL = 0.1
    SignalStatus = Struct.new(:exitstatus) do
      def success?
        exitstatus.zero?
      end
    end

    extend GeneratorHelpers

    # Adds a new hook method that is invoked in the order it is defined
    # @param name [Symbol] unique key defining callback method
    # @yield The body of the generator's callback
    # @return [void]
    def self.add_hook(name, &block)
      self.hooks[name] = block
    end

    # Removes a hook method from the callback chain
    # @param name [Symbol] unique key defining callback method
    # @return [void]
    def self.rem_hook(name)
      self.hooks.delete(name)
    end

    # Returns a hash of callback methods in the order they will be invoked
    # @return [Hash] the callback methods
    def self.hooks
      @hooks ||= from_superclass(:hooks, {})
    end

    # Adds a new option expected from CLI and treats it as an attribute
    # @param name [Symbol] unique key defining option
    # @yield The body of the option's callback which should return a hash
    # @return [void]
    def self.add_option(name, &block)
      attr_reader name
      self._options[name] = block
    end

    # Removes an option expected from the CLI and removes attribute method
    # @param name [Symbol] unique key defining option
    # @return [void]
    def self.rem_option(name)
      undef name
      self._options.delete(name)
    end

    # Returns a hash of options with callbacks that return a hash of their
    # attributes
    # @return [Hash] a hash of options with the corresponding callback
    def self._options
      @options ||= from_superclass(:_options, {})
    end

    # Returns a hash of options that point to a hash of their attributes
    # @return [Hash] a hash of options with the corresponding hash of attributes
    def self.options
      Hash[self._options.map { |k,v| [k, v.call] }]
    end

    # Returns the description of generator
    # @return [String] description of generator
    def self.desc(desc = nil)
      @desc ||= desc
    end

    # Returns the footer description of generator
    # @return [String] footer description of generator
    def self.footer(footer = nil)
      @footer ||= footer
    end

    # @param opts [Hash] various options for controlling the behavior of the generator
    def initialize(opts = {})
      self.class.options.each do |k,v|
        value = opts.fetch(k) do
          raise MissingOption, "missing option: #{k}" if v[:required]
          v[:default]
        end
        value = v[:before_init].call(value) if v[:before_init]
        instance_variable_set("@#{k}", value)
      end
    end

    # Invokes all the callbacks in the order they are defined in the {hooks}
    # hash
    # @return [void]
    def invoke
      self.class.hooks.each {|k,v| self.instance_eval(&v)}
    end

    # Gets an ERB template at the relative source, executes it and makes a copy
    # at the relative destination
    # @param source [String] the relative path to the source file
    # @param destination [String] the relative path to the destination file
    # @return [void]
    def template(source, destination)
      data = File.read File.join(NginxStage.template_root, source)
      create_file destination, render(data)
    end

    # Create a new file at the destination path with the given data
    # @param destination [String] the relative path to the destination file
    # @param data [String] the given data
    # @return [void]
    def create_file(destination, data = "", mode: 0644)
      empty_directory File.dirname(destination)
      File.open(destination, "wb", mode) { |f| f.write data }
    end

    # Create an empty directory if it doesn't already exist
    # @param destination [String] the directory path
    # @param mode [Integer] the mode to set the directory as
    # @return [void]
    def empty_directory(destination, mode: 0755)
      FileUtils.mkdir_p destination, mode: mode
    end

    private

    # Use one stable file for startup, app restart, shutdown, and cleanup.
    # Replacing or removing the PUN config must not replace this lock.
    def with_pun_lifecycle_lock(user:)
      lock_path = "#{NginxStage.pun_config_path(user: user)}.lock"
      FileUtils.mkdir_p File.dirname(lock_path)

      File.open(lock_path, File::RDWR | File::CREAT, 0o644) do |lock|
        lock.flock(File::LOCK_EX)
        yield
      end
    end

    def wait_for_pun_shutdown(user:)
      paths = [NginxStage.pun_socket_path(user: user), NginxStage.pun_pid_path(user: user)]
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + PUN_SHUTDOWN_TIMEOUT

      # Graceful quit unlinks the socket before the master finishes draining.
      # That master can still unlink the shared PID path when it finally exits.
      while paths.any? { |path| path_occupied?(path) }
        if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
          raise Error, "timed out waiting for PUN shutdown for #{user}: socket or PID path still exists"
        end

        sleep PUN_SHUTDOWN_POLL_INTERVAL
      end
    end

    def path_occupied?(path)
      File.exist?(path) || File.symlink?(path)
    end

    def pun_running?(user:)
      pid_path = NginxStage.pun_pid_path(user: user)
      socket_path = NginxStage.pun_socket_path(user: user)
      return false unless path_occupied?(pid_path) || path_occupied?(socket_path)

      # A draining master still owns the PID path even after its socket is gone.
      identity = PunProcess.state(pid_file: PidFile.new(pid_path), user: user)
      return true if identity == :matching
      raise Error, "PUN process identity is uncertain for #{user}; refusing startup" if identity == :unknown
      return false unless path_occupied?(socket_path)

      # A dead master can leave listening orphaned workers or a stale socket.
      # Only cleanup may probe and remove stale socket state under this lock.
      raise Error, "Startup blocked: PUN PID is dead or unrelated but its socket path is occupied for #{user}; " \
                   'retry after scheduled cleanup or contact an administrator'
    rescue MissingPidFile, InvalidPidFile, Errno::ENOENT => e
      raise Error, "PUN PID state is unusable for #{user}: #{e.message}"
    end

    # Keep every nginx command's execution path and shutdown rule in one place.
    # Callers must hold the lifecycle lock where ordering with other operations matters.
    def run_nginx(user:, signal: nil)
      raise Error, 'Startup blocked because a PUN is already running' if signal.nil? && pun_running?(user: user)

      return signal_pun(user: user, signal: signal) if signal

      NginxStage.clean_nginx_env(user: user)
      output, status = Open3.capture2e(
        [NginxStage.nginx_bin, "(#{user})"], *NginxStage.nginx_args(user: user)
      )
      [output, status]
    end

    def signal_pun(user:, signal:)
      pid_file = PidFile.new(NginxStage.pun_pid_path(user: user))
      PunProcess.signal(pid_file: pid_file, user: user, signal: signal)
      wait_for_pun_shutdown(user: user) if ['stop', 'quit'].include?(signal.to_s)
      ['', SignalStatus.new(0)]
    end

    # Retrieves a value from superclass. If it reaches the baseclass,
    # returns default
    def self.from_superclass(method, default = nil)
      if self == NginxStage::Generator || !superclass.respond_to?(method, true)
        default
      else
        superclass.send(method).dup
      end
    end

    # Use ERB to render templates
    def render(data)
      ERB.new(data, trim_mode: '-').result(binding)
    end
  end
end
