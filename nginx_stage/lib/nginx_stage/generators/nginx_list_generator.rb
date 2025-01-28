# frozen_string_literal: true

module NginxStage
  # This generator lists all running per-user NGINX processes.
  class NginxListGenerator < Generator
    desc 'List all user running PUNs'

    footer <<-EOF.gsub(/^ {4}/, '')
    Examples:
        To list all active per-user nginx processes:

            nginx_stage nginx_list

        this lists all users who have actively running PUNs.
    EOF

    # Display active users
    add_hook :display_active_users do
      NginxStage.active_users.each do |u|
        puts u
      end
    end
  end
end
