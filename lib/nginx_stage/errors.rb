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
end
