module NginxStage
  # Base generator that all other generators inherit from. {BaseGenerator} has
  # the common callback methods used in all other generators. In particular it
  # validates the user and determines whether the NGINX process should be
  # called.
  class BaseGenerator < Generator
    # The initial options passed into the constructor
    # @return [Hash] the initial options
    attr_reader :options

    # The user that the per-user NGINX will run as
    # @return [String] the user of the per-user NGINX
    attr_reader :user

    # Whether we skip calling the NGINX process
    # @return [Boolean] If true, skip calling the nginx binary
    attr_reader :skip_nginx

    # @param opts [Hash] various options for controlling the behavior of the generator
    # @option opts [String] :user (nil) the user of the per-user nginx
    # @option opts [Boolean] :skip_nginx (false) whether to skip calling nginx binary
    def initialize(opts)
      @options    = opts.dup
      @user       = opts.fetch(:user, nil)
      @skip_nginx = opts.fetch(:skip_nginx, false)
    end

    #
    # -- Invoke methods --
    #
    # These methods are invoked in the order they are defined. These methods
    # will be called before any other inherited class callback methods.
    #

    # Verify that a user was supplied
    add_hook :require_user do
      raise MissingOption, "missing option: --user=USER" unless user
    end

    # Validate that user exists and isn't a special user
    add_hook :validate_user do
      check_user_exists(user)
      check_user_is_not_special(user)
    end


    private
      # Check that user exists on local system
      def check_user_exists(user)
        Etc.getpwnam(user)
      rescue ArgumentError
        raise InvalidUser, "user doesn't exist: #{user}"
      end

      # Check that user isn't special (i.e., user_id < min_uid)
      def check_user_is_not_special(user)
        passwd = Etc.getpwnam(user)
        raise InvalidUser, "user is special: #{user} (#{passwd.uid} < #{NginxStage.min_uid})" if passwd.uid < NginxStage.min_uid
      end
  end
end
