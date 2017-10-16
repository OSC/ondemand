module NginxStage
  # Module that adds common options to generators.
  module GeneratorHelpers
    # Add support for accepting USER as an option
    # @param required [Boolean] whether user option is required
    # @return [void]
    def add_user_support(required: true)
      # @!method user
      #   The user that the per-user NGINX will run as
      #   @return [User] the user of the nginx process
      #   @raise [MissingOption] if user isn't supplied
      self.add_option :user do
        {
          opt_args: ["-u", "--user=USER", "# The USER of the per-user nginx process"],
          required: required,
          before_init: -> (user) do
            raise InvalidUser, "invalid user name syntax: #{user}" unless user =~ NginxStage.user_regex
            user ? User.new(user) : nil
          end
        }
      end

      if required
        # Validate that the user isn't a special user (i.e., `root`)
        self.add_hook :validate_user_not_special do
          min_uid = NginxStage.min_uid
          if user.uid < min_uid
            raise InvalidUser, "user is special: #{user} (#{user.uid} < #{min_uid})"
          end
        end
      end
    end

    # Add support for accepting SKIP_NGINX as an option
    # @return [void]
    def add_skip_nginx_support
      # @!method skip_nginx
      #   Whether we skip calling the NGINX process
      #   @return [Boolean] if true, skip calling the nginx binary
      add_option :skip_nginx do
        {
          opt_args: ["-N", "--[no-]skip-nginx", "# Skip execution of the per-user nginx process", "# Default: false"],
          default: false
        }
      end
    end

    # Add support for accepting SUB_URI as an option
    # @return [void]
    def add_sub_uri_support
      # @!method sub_uri
      #   The sub-uri that distinguishes the per-user NGINX process
      #   @example An app is requested through '/pun/usr/user/appname/...'
      #     sub_uri #=> "/pun"
      #   @return [String] the sub-uri for nginx
      add_option :sub_uri do
        {
          opt_args: ["-i", "--sub-uri=SUB_URI", "# The SUB_URI that requests the per-user nginx", "# Default: ''"],
          default: '',
          before_init: -> (sub_uri) do
            raise InvalidSubUri, "invalid sub-uri syntax: #{sub_uri}" if sub_uri =~ /[^-\w\/]/
            sub_uri
          end
        }
      end
    end
  end
end
