module NginxStage
  class GenerateBase < Generate
    attr_reader :options

    attr_reader :user
    attr_reader :skip_nginx

    def initialize(opts)
      @options    = opts.dup
      @user       = opts.fetch(:user, nil)
      @skip_nginx = opts.fetch(:skip_nginx, false)
    end

    add_hook :require_user do
      raise MissingOption, "missing option: --user=USER" unless user
    end

    add_hook :validate_user do
      check_user_exists(user)
      check_user_is_special(user)
    end

    private
      def check_user_exists(user)
        Etc.getpwnam(user)
      rescue ArgumentError
        raise InvalidUser, "user doesn't exist: #{user}"
      end

      def check_user_is_special(user)
        passwd = Etc.getpwnam(user)
        raise InvalidUser, "user is special: #{user} (#{passwd.uid} < #{NginxStage.min_uid})" if passwd.uid < NginxStage.min_uid
      end
  end
end
