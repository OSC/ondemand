module NginxStage
  # This generator cleans up any staged app configs whose app root doesn't
  # exist anymore. It will also print out the paths for the app configs it
  # deleted.
  class AppCleanGenerator < Generator
    desc 'Clean up any staged app configs that point to deleted apps'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To clean up all stale app configs:

            nginx_stage app_clean

        this displays the paths of the app configs it deleted.
    EOF

    # Delete staged app configs whose app doesn't exist anymore. Also display
    # the app configs that are deleted.
    add_hook :delete_stale_app_configs do
      NginxStage.staged_apps.each do |env, apps|
        apps.each do |h|
          owner = h[:owner]
          name  = h[:name]
          app_config = NginxStage.app_config_path(env: env, owner: owner, name: name)
          app_root   = NginxStage.app_root(env: env, owner: owner, name: name)
          unless NginxStage.as_user(owner) { File.directory?(app_root) }
            begin
              File.delete app_config
              puts app_config
            rescue
              $stderr.puts "#{$!.to_s}"
            end
          end
        end
      end
    end
  end
end
