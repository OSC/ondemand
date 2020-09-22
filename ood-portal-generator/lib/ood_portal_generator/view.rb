require "digest/sha1"
require "erb"

module OodPortalGenerator
  # A view class that renders an OOD portal Apache configuration file
  class View
    attr_reader :ssl, :protocol, :servername, :port
    attr_accessor :user_map_cmd, :logout_redirect
    attr_accessor :oidc_uri, :oidc_client_secret, :oidc_remote_user_claim, :oidc_client_id, :oidc_provider_metadata_url, :oidc_redirect_uri
    # @param opts [#to_h] the options describing the context used to render the
    #   template
    def initialize(opts = {})
      opts = opts.to_h.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil? }

      # Portal configuration
      @ssl              = opts.fetch(:ssl, nil)
      @protocol         = @ssl ? "https://" : "http://"
      @listen_addr_port = opts.fetch(:listen_addr_port, nil)
      @servername       = opts.fetch(:servername, nil)
      @proxy_server     = opts.fetch(:proxy_server, @servername)
      @port             = opts.fetch(:port, @ssl ? "443" : "80")
      @accesslog        = opts.fetch(:accesslog, "logs/#{@servername ? @servername+'_access' : 'access'}#{@ssl ? '_ssl.log' : '.log'}")
      @errorlog         = opts.fetch(:errorlog, "logs/#{@servername ? @servername+'_error' : 'error'}#{@ssl ? '_ssl.log' : '.log'}")
      @logformat        = opts.fetch(:logformat, nil)
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

      # Portal authentication
      @auth = opts.fetch(:auth, [
        %q{AuthType openid-connect},
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

      servername = @servername || OodPortalGenerator.fqdn
      @oidc_provider_metadata_url       = opts.fetch(:oidc_provider_metadata_url, nil)
      @oidc_client_id                   = opts.fetch(:oidc_client_id, nil)
      @oidc_client_secret               = opts.fetch(:oidc_client_secret, nil)
      @oidc_redirect_uri                = "#{protocol}#{servername}#{@oidc_uri}"
      @oidc_remote_user_claim           = opts.fetch(:oidc_remote_user_claim, 'preferred_username')
      @oidc_scope                       = opts.fetch(:oidc_scope, "openid profile email")
      @oidc_crypto_passphrase           = Digest::SHA1.hexdigest(servername)
      @oidc_session_inactivity_timeout  = opts.fetch(:oidc_session_inactivity_timeout, 28800)
      @oidc_session_max_duration        = opts.fetch(:oidc_session_max_duration, 28800)
      @oidc_state_max_number_of_cookies = opts.fetch(:oidc_state_max_number_of_cookies, '10 true')
      @oidc_cookie_same_site            = opts.fetch(:oidc_cookie_same_site, @ssl ? 'Off' : 'On')
      @oidc_settings                    = opts.fetch(:oidc_settings, {})
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

    def update_oidc_attributes(attrs)
      attrs.each_pair do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
