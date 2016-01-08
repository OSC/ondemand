module NginxStage
  class GenerateAppConfig < Generate
    attr_reader :request

    attr_reader :env
    attr_reader :owner
    attr_reader :app

    attr_reader :app_path
    attr_reader :app_uri

    def initialize(opts)
      super(opts)
      @request = opts.fetch(:request, nil)
    end

    add_hook :require_request do
      raise MissingOption, "missing option: --request=REQUEST" unless request
    end

    add_hook :parse_request do
      matches = request_regex.match(request)
      raise InvalidRequest, "invalid request: #{request}" unless matches
      @env = matches[:env]
      if env == 'dev'
        @owner = user
        @app = matches[:owner]
      else
        @owner = matches[:owner]
        @app = matches[:app]
      end
    end

    add_hook :validate_owner do
      check_user_exists(owner)
    end

    add_hook :validate_environment do
      case env
      when 'dev'
        @app_path = File.expand_path(File.join("~#{owner}", NginxStage.dev_app_relative_root, app))
        @app_uri = "#{NginxStage.sub_uri}/#{env}/#{app}"
      when 'shared'
        @app_path = File.expand_path(File.join("~#{owner}", NginxStage.shr_app_relative_root, app))
        @app_uri = "#{NginxStage.sub_uri}/#{env}/#{owner}/#{app}"
      else
        raise InvalidRequest, "invalid request environment: #{env}"
      end
    end

    add_hook :validate_app_path do
      raise InvalidRequest, "invalid app path: #{app_path}" unless Dir.exists?(app_path)
    end

    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    add_hook :run_nginx do
      if skip_nginx
        app_config_path
      else
        GeneratePunConfig.new(options.merge(signal: :reload)).invoke
      end
    end

    private
      def request_regex
        /^#{NginxStage.sub_uri}\/(?<env>[\w-]+)\/(?<owner>[\w-]+)(?:\/(?<app>[\w-]+))?/
      end

      def app_config_path
        File.join(NginxStage.app_config_root, env, owner, "#{app}.conf")
      end
  end
end
