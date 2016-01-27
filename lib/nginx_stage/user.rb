require 'forwardable'

module NginxStage
  # Class used to describe a user found on the local system.
  class User
    extend Forwardable

    # @!method name
    #   The user name
    #   @return [String] the user name
    # @!method uid
    #   The user's id
    #   @return [Integer] the user id
    # @!method gid
    #   The user's group id
    #   @return [Integer] the group id
    # @!method gecos
    #   The user's real name
    #   @return [String] the real name
    # @!method dir
    #   The user's home directory
    #   @return [String] the home path
    # @!method shell
    #   The user's shell
    #   @return [String] the shell
    delegate [:name, :uid, :gid, :gecos, :dir, :shell] => :@passwd

    # @param user [String] the user name defining this object
    # @raise [InvalidUser] if user doesn't exist on local system
    def initialize(user)
      @passwd = Etc.getpwnam user
      @group = Etc.getgrgid gid
    rescue ArgumentError
      raise InvalidUser, "user doesn't exist: #{user}"
    end

    # User's primary group name
    # @return [String] the primary group name
    def group
      @group.name
    end

    # Members of user's primary group
    # @return [Array<String>] list of users in primary group
    def group_mem
      @group_mem
    end

    # Convert object to string using user name as string value
    # @return [String] the user name
    def to_s
      @passwd.name
    end

    # This object is string-like and returns the user name when treated as a
    # string
    # @return [String] the user name
    def to_str
      @passwd.name
    end
  end
end
