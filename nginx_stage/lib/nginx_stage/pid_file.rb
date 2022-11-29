# frozen_string_literal: true

require 'pathname'

module NginxStage
  # A class to handle a PID file
  class PidFile
    # Process id that describes this object
    # @return [Integer] the pid object was initialized with
    attr_reader :pid

    # @param pid [Integer] the pid describing a process
    # @raise [MissingPidFile] if pid file doesn't exist in file system
    # @raise [InvalidPidFile] if it is an invalid pid file
    def initialize(pid_path)
      @pid_path = Pathname.new(pid_path)
      raise MissingPidFile, "missing PID file: #{pid_path}" unless @pid_path.exist?
      raise InvalidPidFile, "invalid PID file: #{pid_path}" unless @pid_path.file?

      @pid = @pid_path.read.to_i
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
      @pid_path.to_s
    end

    # Path of the PID file
    # @return [String] the path of the pid file
    def pid_path
      @pid_path.to_s
    end

    # Remove the file from the file system
    def delete
      @pid_path.delete
    rescue StandardError
      warn "Unable to delete pid file at #{pid_path}"
    end
  end
end
