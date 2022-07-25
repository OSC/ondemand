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

    include AppConfigView

    # The environment the app is run under (parsed from sub_request)
    # @return [Symbol] environment app is run under
    attr_accessor :env

    # The owner of the app (parsed from sub_request or assume it is user)
    # @return [String] owner of app
    attr_accessor :owner

    # The name of the app
    # @return [String] name of app
    attr_accessor :name

    # Accepts `user` as an option and validates user
    add_user_support

    # Accepts `skip_nginx` as an option
    add_skip_nginx_support

    # Accepts `sub_uri` as an option
    add_sub_uri_support

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

    # Parse the sub_request for the environment, owner, and app name
    add_hook :parse_sub_request do
      info = NginxStage.parse_app_request(request: sub_request)
      self.env   = info.fetch(:env)
      self.owner = info.fetch(:owner, user)
      self.name  = info.fetch(:name, nil)
    end

    # Validate that the path to the app exists on the local filesystem
    add_hook :validate_app_root do
      raise InvalidRequest, "invalid app root: #{app_root}" unless NginxStage.as_user(user) { File.directory?(app_root) }
    end

    # Generate the NGINX app config from the 'app.conf.erb' template
    add_hook :create_config do
      template "app.conf.erb", app_config_path
    end

    # Restart the per-user NGINX process (exit quietly on success)
    add_hook :exec_nginx do
      if !skip_nginx
        NginxStage.nginx_env_reset(env: NginxStage.nginx_env(user: user))
        if File.file? NginxStage.pun_pid_path(user: user)
          o, s = Open3.capture2e(
            [
              NginxStage.nginx_bin,
              "(#{user})"
            ],
            *NginxStage.nginx_args(user: user, signal: :stop)
          )
          abort(o) unless s.success?
        end
        o, s = Open3.capture2e(
          [
            NginxStage.nginx_bin,
            "(#{user})"
          ],
          *NginxStage.nginx_args(user: user)
        )
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
        NginxStage.app_config_path(env: env, owner: owner, name: name)
      end
  end
end
