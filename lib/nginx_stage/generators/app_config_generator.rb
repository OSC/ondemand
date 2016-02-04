module NginxStage
  # This generator stages and generates the NGINX app config. It is also
  # responsible for reloading the per-user NGINX process after updating the app
  # config.
  class AppConfigGenerator < Generator
    desc 'Generate a new nginx app config and reload process'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To generate an app config from a URI request and reload the nginx
        process:

            nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim/container/13

        To generate ONLY the app config from a URI request:

            nginx_stage app --user=bob --sub-uri=/pun --sub-request=/shared/jimmy/fillsim --skip-nginx

        this will return the app config path and won't run nginx.
    EOF

    # Accepts `user` as an option and validates user
    add_user_support

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # @!method sub_request
    #   The remainder of the request after the sub-uri used to determine the
    #   environment and app
    #   @example An app is requested through '/pun/shared/user/appname/...'
    #     sub_request #=> "/shared/user/appname/..."
    #   @return [String] the remainder of the request after sub-uri
    #   @raise [MissingOption] if sub_request isn't supplied
    add_option :sub_request do
      {
        opt_args: ["-r", "--sub-request=SUB_REQUEST", "# The SUB_REQUEST that requests the specified app"],
        required: true
      }
    end

    # @!method sub_uri
    #   The sub-uri that distinguishes the per-user NGINX process
    #   @example An app is requested through '/pun/shared/user/appname/...'
    #     sub_uri #=> "/pun"
    #   @return [String] the sub-uri for nginx
    add_option :sub_uri do
      {
        opt_args: ["-i", "--sub-uri=SUB_URI", "# The SUB_URI that requests the per-user nginx", "# Default: ''"],
        default: ''
      }
    end

    # Parse the sub_request for the environment, owner, and app name
    add_hook :parse_sub_request do
      info = NginxStage.parse_app_request(request: sub_request)
      @app_env   = info.fetch(:env)
      @app_owner = User.new info.fetch(:owner, user.name)
      @app_name  = info.fetch(:name, nil)
    end

    # Validate that the path to the app exists on the local filesystem
    add_hook :validate_app_root do
      raise InvalidRequest, "invalid app root: #{app_root}" unless File.directory?(app_root)
    end

    # Generate the NGINX app config from the 'app.conf.erb' template
    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    # Run the per-user NGINX process through `exec` (so we capture return code)
    add_hook :exec_nginx do
      exec([NginxStage.nginx_bin, "(#{user})"], *NginxStage.nginx_args(user: user, signal: :reload)) unless skip_nginx
    end

    # If we skip nginx, then output the path to the generated NGINX app config
    add_hook :output_app_config_path do
      puts app_config_path
    end

    private
      # NGINX app config path
      def app_config_path
        NginxStage.app_config_path(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # Path to the app root on the local filesystem
      def app_root
        NginxStage.get_app_root(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # The URI used to access the app from the browser
      def app_uri
        app_request = NginxStage.get_app_request(env: @app_env, owner: @app_owner, name: @app_name)
        "#{sub_uri}#{app_request}"
      end

      # The Passenger environment to run app under
      def env
        @app_env == :dev ? "development" : "production"
      end
  end
end
