# frozen_string_literal: true

module NginxStage
  # This generator resets all app configs with the most current app config
  # template.
  class AppResetGenerator < Generator
    desc 'Reset all staged app configs with the current template'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To reset all staged app configs using the currently available app
        config template:

            nginx_stage app_reset --sub-uri=/pun

        this will return the paths to the newly updated app configs.
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

    # Accepts `sub_uri` as an option
    add_sub_uri_support

    # Updates all staged app configs with current template and displays paths
    # to user
    add_hook :update_app_configs do
      NginxStage.staged_apps.each do |env, apps|
        apps.each do |h|
          self.env = env
          self.owner = h[:owner]
          self.name = h[:name]
          template 'app.conf.erb', app_config_path
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
