# frozen_string_literal: true

require 'pathname'

module NginxStage
  # A class to handle a PID file
  class PidFile
    MAX_PID_FILE_BYTES = 22

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

      # Bound the read and require a positive Linux pid_t. PID 0 and negative
      # values would signal a process group instead of one process.
      contents = @pid_path.binread(MAX_PID_FILE_BYTES + 1).to_s
      digits = contents[/\A\s*([0-9]+)\s*\z/, 1] if contents.bytesize <= MAX_PID_FILE_BYTES
      pid = digits&.to_i
      raise InvalidPidFile, "invalid PID file: #{pid_path}" unless pid&.between?(1, 2**31 - 1)

      @pid = pid
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
