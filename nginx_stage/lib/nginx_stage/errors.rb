module NginxStage
  # The root exception class that all NginxStage-specific exceptions inherit from
  class Error < StandardError; end

  # An exception raised when attempting to set an invalid configuration option
  class InvalidConfigOption < Error; end

  # An exception raised when attempting to resolve an option that doesn't exist
  class MissingOption < Error; end

  # An exception raised when attempting to resolve a command that doesn't exist
  class MissingCommand < Error; end

  # An exception raised when attempting to resolve a command that is invalid
  class InvalidCommand < Error; end

  # An exception raised when attempting to resolve a user that is invalid
  class InvalidUser < Error; end

  # An exception raised when attempting to resolve a socket that already exists
  class InvalidSocket < Error; end

  # An exception raised when attempting to resolve an invalid request option
  class InvalidRequest < Error; end

  # An exception raised when attempting to resolve an invalid sub-uri option
  class InvalidSubUri < Error; end

  # An exception raised when attempting to resolve an invalid app-init-url option
  class InvalidAppInitUrl < Error; end

  # An exception raised when attempting to read a pid file that doesn't exist
  class MissingPidFile < Error; end

  # An exception raised when attempting to read an invalid pid file
  class InvalidPidFile < Error; end

  # An exception raised when a Pid file has a process id that isn't running
  class StalePidFile < Error; end

  # An exception raised when attempting to access a socket file that doesn't exist
  class MissingSocketFile < Error; end

  # An exception raised when attempting to access an invalid socket file
  class InvalidSocketFile < Error; end
end
