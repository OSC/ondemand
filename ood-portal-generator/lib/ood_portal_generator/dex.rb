require 'active_support'
require 'active_support/core_ext'
require 'securerandom'
require 'fileutils'

module OodPortalGenerator
  # A view class that renders a Dex configuration
  class Dex
    # @param opts [#to_h] the options describing the context used to render the Dex config
    def initialize(opts = {}, view)
      opts = opts.to_h.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil? }
      config = opts.fetch(:dex, {})
      if config.nil? || config == false
        @enable = false
        return
      else
        config = config.to_h.each_with_object({}) { |(k, v), h| h[k.to_sym] = v unless v.nil? }
        @config = config
        @enable = true
      end
      @view = view
      @dex_config = {}
      @dex_config[:issuer] = issuer
      @dex_config[:storage] = {
        type: 'sqlite3',
        config: { file: storage_file },
      }
      @dex_config[:web] = {
        http: "0.0.0.0:#{http_port}",
      }
      @dex_config[:web][:https] = "0.0.0.0:#{https_port}" if ssl?
      copy_ssl_certs
      @dex_config[:web][:tlsCert] = @tls_cert unless @tls_cert.nil?
      @dex_config[:web][:tlsKey] = @tls_key unless @tls_key.nil?
      @dex_config[:grpc] = grpc unless grpc.nil?
      @dex_config[:expiry] = expiry unless expiry.nil?
      @dex_config[:telemetry] = { http: '0.0.0.0:5558' }
      @dex_config[:staticClients] = static_clients
      @dex_config[:connectors] = connectors unless connectors.nil?
      @dex_config[:oauth2] = { skipApprovalScreen: true }
      @dex_config[:enablePasswordDB] = connectors.nil?
      if connectors.nil?
        @dex_config[:staticPasswords] = [{
          email: 'ood@localhost',
          hash: '$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W',
          username: 'ood',
          userID: '08a8684b-db88-4b73-90a9-3cd1661f5466',
        }]
      end
      @dex_config[:frontend] = {
        dir: '/usr/share/ondemand-dex/web',
        theme: 'ondemand',
      }.merge(frontend)
      # Pass values back to main ood-portal.conf view
      if enabled? && self.class.installed?
        view.update_oidc_attributes(oidc_attributes)
      end
    end

    # Render the config as a YAML string
    # @return [String] YAML string
    def render
      config = @dex_config.deep_transform_keys!(&:to_s)
      config.to_yaml
    end

    def enabled?
      !!@enable
    end

    def self.installed?
      File.directory?(config_dir) && File.executable?('/usr/sbin/ondemand-dex')
    end

    def self.config_dir
      '/etc/ood/dex'
    end

    private

    def ssl?
      @config.fetch(:ssl, !@view.ssl.nil?)
    end

    def protocol
      ssl? ? "https://" : "http://"
    end

    def servername
      @view.servername || OodPortalGenerator.fqdn
    end

    def http_port
      @config.fetch(:http_port, "5556")
    end

    def https_port
      @config.fetch(:https_port, "5554")
    end

    def port
      ssl? ? https_port : http_port
    end

    def tls_cert
      @tls_cert ||= @config.fetch(:tls_cert, nil)
    end

    def tls_key
      @tls_key ||= @config.fetch(:tls_key, nil)
    end

    def issuer
      "#{protocol}#{servername}:#{port}"
    end

    def storage_file
      @config.fetch(:storage_file, File.join(self.class.config_dir, 'dex.db'))
    end

    def grpc
      @config.fetch(:grpc, nil)
    end

    def expiry
      @config.fetch(:expiry, nil)
    end

    def client_protocol
      @view.protocol
    end

    def client_port
      if @view.port && ['443','80'].include?(@view.port.to_s)
        ''
      else
        ":#{@view.port}"
      end
    end

    def client_id
      @config.fetch(:client_id, (@view.servername || OodPortalGenerator.fqdn))
    end

    def client_url
      "#{client_protocol}#{client_id}#{client_port}"
    end

    def client_redirect_uri
      "#{client_url}/oidc"
    end

    def client_redirect_uris
      config_redirect_uris = @config.fetch(:client_redirect_uris, [])
      [client_redirect_uri] + config_redirect_uris
    end

    def client_name
      @config.fetch(:client_name, "OnDemand")
    end

    def default_secret_path
      File.join(self.class.config_dir, "ondemand.secret")
    end

    def generate_secret
      return default_secret_path if (File.exist?(default_secret_path) && ! File.zero?(default_secret_path))

      secret = SecureRandom.uuid
      File.open(default_secret_path, "w", 0600) { |f| f.write("#{secret}\n") }
      FileUtils.chown(OodPortalGenerator.dex_user, OodPortalGenerator.dex_group, default_secret_path)
      default_secret_path
    end

    def client_secret
      return nil unless self.class.installed? && enabled?

      secret = @config.fetch(:client_secret) { generate_secret }
      secret = File.read(secret).strip if File.exist?(secret)
      secret
    end

    def static_clients
      ood_client = {
        id: client_id,
        redirectURIs: client_redirect_uris,
        name: client_name,
        secret: client_secret,
      }
      config_clients = @config.fetch(:static_clients, [])
      [ood_client] + config_clients
    end

    def connectors
      @config.fetch(:connectors, nil)
    end

    def frontend
      @config.fetch(:frontend, {})
    end

    def copy_ssl_certs
      return if !ssl? || @view.ssl.nil? || ! tls_cert.nil? || ! tls_key.nil?
      @view.ssl.each do |ssl_line|
        items = ssl_line.split(' ', 2)
        next unless items.size == 2
        value = items[1].gsub(/"|'/, '')
        newpath = File.join(self.class.config_dir, File.basename(value))
        case items[0].downcase
        when 'sslcertificatefile'
          @tls_cert = newpath
        when 'sslcertificatekeyfile'
          @tls_key = newpath
        else
          next
        end
        if File.exists?(value) && self.class.installed? && enabled?
          FileUtils.cp(value, newpath, preserve: true, verbose: true)
          FileUtils.chown(OodPortalGenerator.dex_user, OodPortalGenerator.dex_group, newpath, verbose: true)
        end
      end
    end

    def oidc_attributes
      attrs = {
        oidc_uri: '/oidc',
        oidc_redirect_uri: client_redirect_uri,
        oidc_provider_metadata_url: "#{issuer}/.well-known/openid-configuration",
        oidc_client_id: client_id,
        oidc_client_secret: client_secret,
      }
      attrs[:oidc_remote_user_claim] = 'email' if connectors.nil?
      if @view.oidc_remote_user_claim == 'email' || attrs[:oidc_remote_user_claim] == 'email'
        attrs[:user_map_cmd] = "/opt/ood/ood_auth_map/bin/ood_auth_map.regex --regex='^([^@]+)@.*$'"
      end
      attrs[:logout_redirect] = "/oidc?logout=#{client_url}".gsub('://', '%3A%2F%2F')
      attrs
    end
  end
end
