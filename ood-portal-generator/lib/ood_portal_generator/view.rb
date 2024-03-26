require "digest/sha1"
require "erb"
require 'socket'

module OodPortalGenerator
  # A view class that renders an OOD portal Apache configuration file
  class View
    attr_reader :ssl, :protocol, :proxy_server, :port, :dex_uri
    attr_accessor :user_map_match, :user_map_cmd, :logout_redirect, :dex_http_port, :dex_enabled
    attr_accessor :oidc_uri, :oidc_client_secret, :oidc_remote_user_claim, :oidc_client_id, :oidc_provider_metadata_url

    # let the application set the auth if it needs to
    attr_writer :auth

    # @param opts [#to_h] the options describing the context used to render the
    #   template
    def initialize(opts = {})
      opts = {} unless opts.respond_to?(:to_h)
      opts = opts.to_h.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil? }

      # Portal configuration
      @ssl              = opts.fetch(:ssl, nil)
      @protocol         = @ssl ? "https://" : "http://"
      @listen_addr_port = opts.fetch(:listen_addr_port, nil)
      @servername       = opts.fetch(:servername, nil)
      @server_aliases   = opts.fetch(:server_aliases, [])
      @proxy_server     = opts.fetch(:proxy_server, servername)
      @allowed_hosts    = allowed_hosts
      @port             = opts.fetch(:port, @ssl ? "443" : "80")
      if OodPortalGenerator.debian?
        @logroot        = opts.fetch(:logroot, "/var/log/apache2")
      else
        @logroot        = opts.fetch(:logroot, "logs")
      end
      access_log        = opts.fetch(:accesslog, nil)
      error_log         = opts.fetch(:errorlog, nil)
      @disable_logs     = opts.fetch(:disable_logs, false)
      @accesslog        = log_filename(access_log,"access")
      @errorlog         = log_filename(error_log,"error")
      @logformat        = opts.fetch(:logformat, nil)
      @use_rewrites     = opts.fetch(:use_rewrites, true)
      @lua_root         = opts.fetch(:lua_root, "/opt/ood/mod_ood_proxy/lib")
      @lua_log_level    = opts.fetch(:lua_log_level, "info")
      @user_map_cmd     = opts.fetch(:user_map_cmd, nil)
      @user_map_match   = @user_map_cmd ? nil : opts.fetch(:user_map_match, ".*")
      @user_env         = opts.fetch(:user_env, nil)
      @map_fail_uri     = opts.fetch(:map_fail_uri, nil)
      @pun_stage_cmd    = opts.fetch(:pun_stage_cmd, "sudo /opt/ood/nginx_stage/sbin/nginx_stage")

      # custom directives
      @custom_vhost_directives     = opts.fetch(:custom_vhost_directives, [])
      @custom_location_directives  = opts.fetch(:custom_location_directives, [])

      # Maintenance configuration
      @use_maintenance          = opts.fetch(:use_maintenance, true)
      @maintenance_ip_allowlist = Array(opts.fetch(:maintenance_ip_allowlist, nil) || opts.fetch(:maintenance_ip_whitelist, []))

      # Security configuration
      @security_csp_frame_ancestors = opts.fetch(:security_csp_frame_ancestors, "#{@protocol}#{@proxy_server}")
      @security_strict_transport = opts.fetch(:security_strict_transport, !@ssl.nil?)

      # Portal authentication
      @auth = opts.fetch(:auth, [])

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
      @nginx_uri              = opts.fetch(:nginx_uri, "/nginx")
      @pun_uri                = opts.fetch(:pun_uri, "/pun")
      @pun_socket_root        = opts.fetch(:pun_socket_root, "/var/run/ondemand-nginx")
      @pun_max_retries        = opts.fetch(:pun_max_retries, 5)
      @pun_pre_hook_exports   = opts.fetch(:pun_pre_hook_exports, nil)
      @pun_pre_hook_root_cmd  = opts.fetch(:pun_pre_hook_root_cmd, nil)

      # OpenID Connect sub-uri
      @oidc_uri           = opts.fetch(:oidc_uri, nil)
      @oidc_discover_uri  = opts.fetch(:oidc_discover_uri, nil)
      @oidc_discover_root = opts.fetch(:oidc_discover_root, nil)

      # Register unmapped user sub-uri
      @register_uri  = opts.fetch(:register_uri, nil)
      @register_root = opts.fetch(:register_root, nil)

      @dex_uri                          = opts.fetch(:dex_uri, '/dex')
      @dex_http_port                    = opts.fetch(:dex_http_port, nil)
      @oidc_provider_metadata_url       = opts.fetch(:oidc_provider_metadata_url, nil)
      @oidc_client_id                   = opts.fetch(:oidc_client_id, nil)
      @oidc_client_secret               = opts.fetch(:oidc_client_secret, nil)
      @oidc_remote_user_claim           = opts.fetch(:oidc_remote_user_claim, 'preferred_username')
      @oidc_scope                       = opts.fetch(:oidc_scope, "openid profile email")
      @oidc_crypto_passphrase           = opts.fetch(:oidc_crypto_passphrase, Digest::SHA1.hexdigest(servername))
      @oidc_session_inactivity_timeout  = opts.fetch(:oidc_session_inactivity_timeout, 28800)
      @oidc_session_max_duration        = opts.fetch(:oidc_session_max_duration, 28800)
      @oidc_state_max_number_of_cookies = opts.fetch(:oidc_state_max_number_of_cookies, '10 true')
      @oidc_cookie_same_site            = opts.fetch(:oidc_cookie_same_site, @ssl ? 'Off' : 'On')
      @oidc_settings                    = opts.fetch(:oidc_settings, {})
    end

    def servername
      @servername || OodPortalGenerator.fqdn
    end

    def auth?
      !@auth.empty?
    end

    # Helper method to set the filename and path for access and error logs
    def log_filename(value,log_type)
      return "#{@logroot}/#{value}" unless value.nil?

      prefix = "#{servername}_#{log_type}"
      suffix = @ssl ? '_ssl.log' : '.log'
      "#{@logroot}/#{prefix}#{suffix}"
    end

    def allowed_hosts
      config_hosts = []

      add_servername_or_ips(config_hosts)
      config_hosts << @proxy_server unless @proxy_server.nil?
      config_hosts.concat(@server_aliases)

      return nil if config_hosts.empty?

      config_hosts.sort.uniq
    end

    def add_servername_or_ips(config_hosts)
      # if @servername is nil, they're trying to use ip addresses
      if @servername.nil?
        config_hosts.concat(ip_addresses)
      else
        config_hosts << @servername
      end
    end

    def ip_addresses
      Socket.ip_address_list.select(&:ipv4?)
                            .reject(&:ipv4_loopback?)
                            .map(&:ip_address)
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
      ERB.new(str, trim_mode: "-").result(binding)
    end

    def update_oidc_attributes(attrs)
      attrs.each_pair do |key, value|
        instance_variable_set("@#{key}", value)
      end

      @auth = Dex.default_auth unless auth?
    end
  end
end
