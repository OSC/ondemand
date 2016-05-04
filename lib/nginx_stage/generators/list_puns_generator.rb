module NginxStage
  # This generator lists all running per-user NGINX processes.
  class ListPunsGenerator < Generator
    desc 'List all user running PUNs'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
    EOF

    # Display active users
    add_hook :display_active_users do
      NginxStage.active_users.each do |u|
        puts u
      end
    end
  end
end
