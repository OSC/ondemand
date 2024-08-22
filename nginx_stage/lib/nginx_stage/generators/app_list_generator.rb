# frozen_string_literal: true

module NginxStage
  # This generator lists all staged apps with app configs.
  class AppListGenerator < Generator
    desc 'List all staged app configs'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To list all staged app configs:

            nginx_stage app_list

        this will return the paths to all the staged app configs.
    EOF

    # Displays a list of all staged app configs
    add_hook :print_staged_app_configs do
      NginxStage.staged_apps.each do |env, apps|
        apps.each do |h|
          puts NginxStage.app_config_path(env: env, owner: h[:owner], name: h[:name])
        end
      end
    end
  end
end
