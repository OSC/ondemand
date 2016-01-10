module NginxStage
  class GenerateAppConfig < GenerateBase
    attr_reader :sub_uri
    attr_reader :sub_request

    attr_reader :env
    attr_reader :owner
    attr_reader :app

    def initialize(opts)
      super(opts)
      @sub_uri     = opts.fetch(:sub_uri, nil)
      @sub_request = opts.fetch(:sub_request, nil)
    end

    add_hook :require_sub_request do
      raise MissingOption, "missing option: --sub-request=SUB_REQUEST" unless sub_request
    end

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

    add_hook :validate_owner do
      check_user_exists(owner)
    end

    add_hook :validate_app_path do
      raise InvalidRequest, "invalid app path: #{app_path}" unless Dir.exists?(app_path)
    end

    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    add_hook :run_nginx do
      GeneratePunConfig.new(options.merge(signal: :reload)).invoke unless skip_nginx
    end

    add_hook :return_app_config_path do
      app_config_path
    end

    private
      def app_config_path
        File.join(NginxStage.app_config_root, env.to_s, owner, "#{app}.conf")
      end

      def app_path
        app_root = NginxStage.app_root.fetch(env) do
          raise InvalidRequest, "invalid request environment for app path: #{env}"
        end % {owner: owner}
        File.expand_path(File.join(app_root, app))
      end

      def app_uri
        app_namespace = NginxStage.app_namespace.fetch(env) do
          raise InvalidRequest, "invalid request environment for app namespace: #{env}"
        end % {owner: owner, app: app}
        "#{sub_uri}/#{env}/#{app_namespace}"
      end

      def app_request_regex
        NginxStage.app_request_regex.fetch(env) do
          raise InvalidRequest, "invalid request environment: #{env}"
        end
      end
  end
end
