module NginxStage
  # This generator stages and generates the NGINX app config. It is also
  # responsible for reloading the per-user NGINX process after updating the app
  # config.
  class AppConfigGenerator < BaseGenerator
    # The sub-uri that distinguishes the per-user NGINX process
    # @example An app is requested through '/pun/shared/user/appname/...'
    #   generator.sub_uri #=> "/pun"
    # @return [String] the sub-uri for nginx
    attr_reader :sub_uri

    # The remainder of the request after the sub-uri used to determine the
    # environment and app
    # @example An app is requested through '/pun/shared/user/appname/...'
    #   generator.sub_request #=> "/shared/user/appname/..."
    # @return [String] the remainder of the request after sub-uri
    attr_reader :sub_request

    # The environment the NGINX app is staged under
    # @example A dev app
    #   generator.env #=> "dev"
    # @example A shared app
    #   generator.env #=> "shared"
    # @return [String] the app environment
    attr_reader :env

    # The owner of the app code
    # @return [String] owner of the app
    attr_reader :owner

    # The name of the app
    # @return [String] name of the app
    attr_reader :app

    # @param opts [Hash] various options for controlling the behavior of the generator
    # @option opts [String] :user (nil) the user of the per-user nginx
    # @option opts [Boolean] :skip_nginx (false) whether to skip calling nginx binary
    # @option opts [String] :sub_uri (nil) the sub-uri for nginx
    # @option opts [String] :sub_request (nil) the remainder of the request after sub-uri
    # @see BaseGenerator#initialize
    def initialize(opts)
      super(opts)
      @sub_uri     = opts.fetch(:sub_uri, nil)
      @sub_request = opts.fetch(:sub_request, nil)
    end

    #
    # -- Invoke methods --
    #
    # These methods are invoked in the order they are defined. These methods
    # will be called before any other inherited class callback methods.
    #
    # These methods will be called after the BaseGenerator callbacks.
    #

    # Verify that a sub_request was supplied
    add_hook :require_sub_request do
      raise MissingOption, "missing option: --sub-request=SUB_REQUEST" unless sub_request
    end

    # Parse the sub_request for the environment, owner, and app name
    add_hook :parse_sub_request do
      # Get environment
      if %r[^/(?<env>[\w-]+)(?<app_request>.*)$] =~ sub_request
        @env = env.to_sym
      else
        raise InvalidRequest, "invalid request: missing environment"
      end

      # Get owner/app from rest of request
      if matches = app_request_regex.match(app_request)
        @owner = matches.names.include?('owner') ? matches[:owner] : user
        @app   = matches[:app]
      else
        raise InvalidRequest, "invalid request for app: #{app_request}"
      end
    end

    # Validate that the owner exists on local system
    add_hook :validate_owner do
      check_user_exists(owner)
    end

    # Validate that the path to the app exists on the local filesystem
    add_hook :validate_app_path do
      raise InvalidRequest, "invalid app path: #{app_path}" unless Dir.exists?(app_path)
    end

    # Generate the NGINX app config from the 'app.conf.erb' template
    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    # Reload the per-user NGINX process through `exec` (so we capture return
    # code) if we don't :skip_nginx
    add_hook :run_nginx do
      PunConfigGenerator.new(options.merge(signal: :reload)).invoke unless skip_nginx
    end

    # If we skip nginx, then return the path to the generated NGINX app config
    add_hook :return_app_config_path do
      app_config_path
    end

    private
      # Path to generated NGINX app config
      #   /var/lib/nginx/config/<env>/<owner>/<app>.conf
      def app_config_path
        File.join(NginxStage.app_config_root, env.to_s, owner, "#{app}.conf")
      end

      # Path the actual app on the local filesystem
      #   ~<owner>/<app_root>/<app>
      #   ~bob/ood_dev/rails2
      #   ~jim/ood_shared/fillsim
      def app_path
        app_root = NginxStage.app_root.fetch(env) do
          raise InvalidRequest, "invalid request environment for app path: #{env}"
        end % {owner: owner}
        File.expand_path(File.join(app_root, app))
      end

      # The URI used to access the app from the browser
      #   <sub_uri>/<env>/<app_namespace>
      #   /pun/dev/rails1
      #   /pun/shared/bob/fillsim
      def app_uri
        app_namespace = NginxStage.app_namespace.fetch(env) do
          raise InvalidRequest, "invalid request environment for app namespace: #{env}"
        end % {owner: owner, app: app}
        "#{sub_uri}/#{env}/#{app_namespace}"
      end

      # Regex used to parse an app_namespace
      #   /dev/rails1/structure/1        => owner=<user> & app=rails1
      #   /shared/bob/fillsim/containers => owner=bob    & app=fillsim
      def app_request_regex
        NginxStage.app_request_regex.fetch(env) do
          raise InvalidRequest, "invalid request environment: #{env}"
        end
      end
  end
end
