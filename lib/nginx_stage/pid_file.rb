module NginxStage
  # A class to handle a PID file
  class PidFile
    # Path of the PID file
    # @return [String] the path of the pid file
    attr_reader :pid_path

    # Process id that describes this object
    # @return [Integer] the pid object was initialized with
    attr_reader :pid

    # @param pid [Integer] the pid describing a process
    # @raise [MissingPidFile] if pid file doesn't exist in file system
    # @raise [InvalidPidFile] if it is an invalid pid file
    def initialize(pid_path)
      @pid_path = pid_path
      raise MissingPidFile, "missing PID file: #{pid_path}" unless File.exist?(pid_path)
      raise InvalidPidFile, "invalid PID file: #{pid_path}" unless File.file?(pid_path)
      @pid = File.read(pid_path).to_i
    end

    # Whether the corresponding pid is a running process
    # @return [Boolean] whether it is a running process
    def running_process?
      Process.getpgid @pid
      true
    rescue Errno::ESRCH
      false
    end

    # Convert object to string
    # @return [String] the pid path
    def to_s
      pid_path.to_s
    end
  end
end
