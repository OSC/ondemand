require "erb"

module OodPortalGenerator
  # A view class that renders an OOD portal Apache configuration file
  class View
    # @param opts [#to_h] the options describing the context used to render the
    #   template
    def initialize(opts = {})
      opts = opts.to_h.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil? }

      # Portal configuration
      @ssl              = opts.fetch(:ssl, nil)
      @listen_addr_port = opts.fetch(:listen_addr_port, nil)
      @servername       = opts.fetch(:servername, nil)
      @proxy_server     = opts.fetch(:proxy_server, @servername)
      @port             = opts.fetch(:port, @ssl ? "443" : "80")
      @logroot          = opts.fetch(:logroot, "logs")
      @use_rewrites     = opts.fetch(:use_rewrites, true)
      @lua_root         = opts.fetch(:lua_root, "/opt/ood/mod_ood_proxy/lib")
      @lua_log_level    = opts.fetch(:lua_log_level, "info")
      @user_map_cmd     = opts.fetch(:user_map_cmd, "/opt/ood/ood_auth_map/bin/ood_auth_map.regex")
      @user_env         = opts.fetch(:user_env, nil)
      @map_fail_uri     = opts.fetch(:map_fail_uri, nil)
      @pun_stage_cmd    = opts.fetch(:pun_stage_cmd, "sudo /opt/ood/nginx_stage/sbin/nginx_stage")

      # Maintenance configuration
      @use_maintenance          = opts.fetch(:use_maintenance, true)
      @maintenance_ip_whitelist = Array(opts.fetch(:maintenance_ip_whitelist, []))

      if OodPortalGenerator.scl_apache?
        default_htpasswd = "/opt/rh/httpd24/root/etc/httpd/.htpasswd"
      else
        default_htpasswd = "/etc/httpd/.htpasswd"
      end

      # Portal authentication
      @auth = opts.fetch(:auth, [
        %q{AuthType Basic},
        %q{AuthName "Private"},
        %Q{AuthUserFile "#{default_htpasswd}"},
        %q{RequestHeader unset Authorization},
        %q{Require valid-user}
      ])

      # Redirect for the root uri
      @root_uri = opts.fetch(:root_uri, "/pun/sys/dashboard")

      # Portal analytics
      @analytics = opts.fetch(:analytics, nil)

      #
      # Available sub-uri's and their configurations
      #

      # Pubic sub-uri
      @public_uri  = opts.fetch(:public_uri, "/public")
      @public_root = opts.fetch(:public_root, "/var/www/ood/public")

      # Logout sub-uri
      @logout_uri      = opts.fetch(:logout_uri, "/logout")
      @logout_redirect = opts.fetch(:logout_redirect, "/pun/sys/dashboard/logout")

      # Basic reverse proxy sub-uri
      @host_regex = opts.fetch(:host_regex, "[^/]+")
      @node_uri   = opts.fetch(:node_uri, nil)
      @rnode_uri  = opts.fetch(:rnode_uri, nil)

      # Per-user NGINX sub-uri
      @nginx_uri       = opts.fetch(:nginx_uri, "/nginx")
      @pun_uri         = opts.fetch(:pun_uri, "/pun")
      @pun_socket_root = opts.fetch(:pun_socket_root, "/var/run/ondemand-nginx")
      @pun_max_retries = opts.fetch(:pun_max_retries, 5)

      # OpenID Connect sub-uri
      @oidc_uri           = opts.fetch(:oidc_uri, nil)
      @oidc_discover_uri  = opts.fetch(:oidc_discover_uri, nil)
      @oidc_discover_root = opts.fetch(:oidc_discover_root, nil)

      # Register unmapped user sub-uri
      @register_uri  = opts.fetch(:register_uri, nil)
      @register_root = opts.fetch(:register_root, nil)
    end

    # Helper method to escape IP for maintenance rewrite condition
    def escape_ip(value)
      # Value is already escaped
      if value.split(%r{\\.}, 4).size == 4
        value
      else
        value.split('.', 4).join('\.')
      end
    end

    # Render the provided template as a string
    # @return [String] rendered template
    def render(str)
      ERB.new(str, nil, "-").result(binding)
    end
  end
end
