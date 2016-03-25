module NginxStage
  # Module that adds common options to generators.
  module GeneratorHelpers
    # Add support for accepting USER as an option
    # @return [void]
    def add_user_support
      # @!method user
      #   The user that the per-user NGINX will run as
      #   @return [User] the user of the nginx process
      #   @raise [MissingOption] if user isn't supplied
      self.add_option :user do
        {
          opt_args: ["-u", "--user=USER", "# The USER of the per-user nginx process"],
          required: true,
          before_init: -> (user) do
            raise InvalidUser, "invalid user name syntax: #{user}" if user =~ /[^\w]/
            User.new user
          end
        }
      end

      # Validate that the user isn't a special user (i.e., `root`)
      self.add_hook :validate_user_not_special do
        min_uid = NginxStage.min_uid
        if user.uid < min_uid
          raise InvalidUser, "user is special: #{user} (#{user.uid} < #{min_uid})"
        end
      end

      # Validate that user is in a white-listed group for running apps
      self.add_hook :validate_user_group do
        if valid_groups = NginxStage.user_groups
          found = valid_groups & user.groups
          raise InvalidUser, "user (#{user}) not in valid groups: #{valid_groups.join(', ')}" if found.empty?
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
  end
end
