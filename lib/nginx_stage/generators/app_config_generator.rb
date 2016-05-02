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

            nginx_stage app --user=bob --sub-uri=/pun --sub-request=/usr/jimmy/fillsim/container/13

        To generate ONLY the app config from a URI request:

            nginx_stage app --user=bob --sub-uri=/pun --sub-request=/usr/jimmy/fillsim --skip-nginx

        this will return the app config path and won't run nginx.
    EOF

    # Accepts `user` as an option and validates user
    add_user_support

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # @!method sub_request
    #   The remainder of the request after the sub-uri used to determine the
    #   environment and app
    #   @example An app is requested through '/pun/usr/user/appname/...'
    #     sub_request #=> "/usr/user/appname/..."
    #   @return [String] the remainder of the request after sub-uri
    #   @raise [MissingOption] if sub_request isn't supplied
    add_option :sub_request do
      {
        opt_args: ["-r", "--sub-request=SUB_REQUEST", "# The SUB_REQUEST that requests the specified app"],
        required: true
        # sub-request is validated in `NginxStage::parse_app_request`
      }
    end

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

    # Restart the per-user NGINX process (exit quietly on success)
    add_hook :exec_nginx do
      if !skip_nginx
        if File.file? NginxStage.pun_pid_path(user: user)
          o, s = Open3.capture2e([NginxStage.nginx_bin, "(#{user})"], *NginxStage.nginx_args(user: user, signal: :stop))
          abort(o) unless s.success?
        end
        o, s = Open3.capture2e([NginxStage.nginx_bin, "(#{user})"], *NginxStage.nginx_args(user: user))
        s.success? ? exit : abort(o)
      end
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
        NginxStage.app_root(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # The URI used to access the app from the browser
      def app_request_uri
        "#{sub_uri}#{NginxStage.app_request_uri(env: @app_env, owner: @app_owner, name: @app_name)}"
      end

      # The Passenger environment to run app under
      def env
        NginxStage.app_passenger_env(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # The token used to identify an app
      def app_token
        NginxStage.app_token(env: @app_env, owner: @app_owner, name: @app_name)
      end

      # Have all apps phone home for analytics (required by OOD proposal)
      def google_analytics
        <<-EOF.gsub("'", %q{\\\'})
          <script>
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','https://www.google-analytics.com/analytics.js','_gaOodMetrics');

            _gaOodMetrics('create', 'UA-66793213-1', 'auto', {
              'cookieName': '_gaOodMetrics'
            });
            _gaOodMetrics('set', 'anonymizeIP', 'true');
            _gaOodMetrics('set', '&uid', '#{user.name}');
            _gaOodMetrics('set', 'dimension1', '#{app_token}');
            _gaOodMetrics('set', 'dimension2', '#{user.name}');
            _gaOodMetrics('send', 'pageview');
          </script>
        EOF
      end
  end
end
