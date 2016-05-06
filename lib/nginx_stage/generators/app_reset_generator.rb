module NginxStage
  # This generator resets all app configs with the most current app config
  # template.
  class AppResetGenerator < Generator
    desc 'Reset all app configs with the current template'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
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

    add_hook :blah do
      NginxStage.staged_apps.each do |env, apps|
        apps.each do |h|
          self.env = env
          self.owner = h[:owner]
          self.name = h[:name]
          template "app.conf.erb", app_config_path
          puts app_config_path
        end
      end
    end

    private
      # NGINX app config path
      def app_config_path
        NginxStage.app_config_path(env: env, owner: owner, name: name)
      end
  end
end
