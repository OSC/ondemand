require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__
require 'tempfile'

describe OodPortalGenerator::Application do
  let(:sum_path) do
    Tempfile.new('sum')
  end

  let(:apache) do
    Tempfile.new('apache')
  end

  let(:dex_config) do
    Tempfile.new('dex.yaml')
  end

  let(:dex_secret_path) do
    Tempfile.new('secret')
  end

  let(:user) { user = Etc.getpwuid.name }
  let(:group) do
    gid = Etc.getpwnam(user).gid
    group = Etc.getgrgid(gid).name
  end

  let(:oidc_auth){
    { auth: [ 'AuthType openid-connect', 'Require valid-user' ] }
  }

  before(:each) do
    stub_const('ARGV', [])
    allow(described_class).to receive(:sum_path).and_return(sum_path.path)
    allow(described_class).to receive(:dex_config).and_return(dex_config.path)
    allow(OodPortalGenerator).to receive(:fqdn).and_return('example.com')
    allow(OodPortalGenerator).to receive(:apache_group).and_return('apache')
    allow(OodPortalGenerator).to receive(:dex_user).and_return(user)
    allow(OodPortalGenerator).to receive(:dex_group).and_return(group)
    allow(OodPortalGenerator).to receive(:debian?).and_return(false)
    allow_any_instance_of(OodPortalGenerator::Dex).to receive(:default_secret_path).and_return(dex_secret_path.path)
    allow(SecureRandom).to receive(:uuid).and_return('83bc78b7-6f5e-4010-9d80-22f328aa6550')
    allow(Socket).to receive(:ip_address_list).and_return([Addrinfo.ip("8.8.8.8")])
  end

  after(:each) do
    sum_path.unlink
    apache.unlink
  end

  describe 'generate' do
    def test_generate(input, output)
      expected = read_fixture(output)

      with_modified_env({'CONFIG' => fixture_path(input).to_s }) do
        expect(described_class.output).to receive(:write).with(expected)
        described_class.generate()
      end
    end

    it 'runs generate' do
      expect { described_class.generate() }.to output(/VirtualHost/).to_stdout
    end

    it 'generates default template' do
      test_generate('/dev/null', 'ood-portal.conf.default')
    end

    it 'generates default template for Debian based systems' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(true)
      # same file as above
      test_generate('/dev/null', 'ood-portal.conf.default')
    end

    it 'generates a template with all configurations supplied' do
      config = YAML.load(read_fixture('ood_portal.yaml.all'))
      allow(described_class).to receive(:context).and_return(config)
      expected_rendered = read_fixture('ood-portal.conf.all')

      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end

    it 'generates without maintenance' do
      config = { use_maintenance: false }.merge(oidc_auth)
      allow(described_class).to receive(:context).and_return(config)
      test_generate('/dev/null', 'ood-portal.conf.nomaint')
    end

    it 'generates maintenance template with IP whitelist' do
      config = { maintenance_ip_whitelist: ['192.168.1..*', '10.0.0..*'] }.merge(oidc_auth)
      allow(described_class).to receive(:context).and_return(config)
      test_generate('/dev/null', 'ood-portal.conf.maint_with_ips')
    end

    it 'generates maintenance template with IP whitelist already escaped' do
      config = {maintenance_ip_whitelist: ['192\.168\.1\..*', '10\.0\.0\..*']}.merge(oidc_auth)
      allow(described_class).to receive(:context).and_return(config)
      test_generate('/dev/null', 'ood-portal.conf.maint_with_ips')
    end

    it 'adheres to maintenance_ip_allowlist' do
      test_generate('input/allowlist.yml', 'output/allowlist.conf')
    end

    it 'continue to support maintenance_ip_allowlist' do
      test_generate('input/whitelist.yml', 'output/allowlist.conf')
    end

    it 'allowlist takes precedence over whitelist' do
      test_generate('input/both_lists.yml', 'output/allowlist.conf')
    end

    it 'disable logs when disable_logs is set' do
      test_generate('input/no_logs.yml', 'output/no_logs.conf')
    end

    # similar to test above, only input file has acceslog and logformat configured.
    it 'disable logs when disable_logs is set and other log config is set' do
      test_generate('input/no_logs_w_log_config.yml', 'output/no_logs.conf')
    end

    it 'skip logroot if using piped logs' do
      test_generate('input/piped_logs.yml', 'output/piped_logs.conf')
    end

    it 'templates custom vhost directives' do
      test_generate('input/custom_vhost_directives.yml', 'output/custom_vhost_directives.conf')
    end

    it 'templates custom location directives' do
      test_generate('input/custom_location_directives.yml', 'output/custom_location_directives.conf')
    end

    it 'templates custom location and vhost directives' do
      test_generate('input/custom_directives.yml', 'output/custom_directives.conf')
    end

    it 'http_redirect_host can be set' do
      test_generate('input/http_redirect_host.yml', 'output/http_redirect_host.conf')
    end

    it 'generates full OIDC config' do
      config = {
        servername: 'ondemand.example.com',
        oidc_uri: '/oidc',
        oidc_provider_metadata_url: 'https://idp.example.com/auth/realms/osc/.well-known/openid-configuration',
        oidc_client_id: 'ondemand.example.com',
        oidc_client_secret: 'secret',
        oidc_remote_user_claim: 'preferred_username',
        oidc_scope: 'openid profile email groups',
        oidc_session_inactivity_timeout: 28800,
        oidc_session_max_duration: 28800,
        oidc_state_max_number_of_cookies: '10 true',
        oidc_settings: {
          OIDCPassIDTokenAs: 'serialized',
          OIDCPassRefreshToken: 'On',
          OIDCPassClaimsAs: 'environment',
          OIDCStripCookies: 'mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1',
        },
      }.merge(oidc_auth)
      allow(described_class).to receive(:context).and_return(config)
      expected_rendered = read_fixture('ood-portal.conf.oidc')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end
    it 'generates full OIDC config with SSL' do
      config = {
        servername: 'ondemand.example.com',
        port: '443',
        ssl: [
          'SSLCertificateFile /etc/pki/tls/certs/ondemand.example.com.crt',
          'SSLCertificateKeyFile /etc/pki/tls/private/ondemand.example.com.key',
          'SSLCertificateChainFile /etc/pki/tls/certs/ondemand.example.com-interm.crt',
        ],
        oidc_uri: '/oidc',
        oidc_provider_metadata_url: 'https://idp.example.com/auth/realms/osc/.well-known/openid-configuration',
        oidc_client_id: 'ondemand.example.com',
        oidc_client_secret: 'secret',
        oidc_remote_user_claim: 'preferred_username',
        oidc_scope: 'openid profile email groups',
        oidc_session_inactivity_timeout: 28800,
        oidc_session_max_duration: 28800,
        oidc_state_max_number_of_cookies: '10 true',
        oidc_settings: {
          OIDCPassIDTokenAs: 'serialized',
          OIDCPassRefreshToken: 'On',
          OIDCPassClaimsAs: 'environment',
          OIDCStripCookies: 'mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1',
        },
      }.merge(oidc_auth)
      allow(described_class).to receive(:context).and_return(config)
      expected_rendered = read_fixture('ood-portal.conf.oidc-ssl')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end

    it 'genereates the correct debian portal with auth' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(true)
      test_generate('input/auth.yml', 'output/auth_deb.conf')
    end

    it 'generates scriptalias for register' do
      test_generate('input/register-scriptalias.yml', 'output/register-scriptalias.conf')
    end

    it 'generates wsgiscriptalias for register' do
      test_generate('input/register-wsgiscriptalias.yml', 'output/register-wsgiscriptalias.conf')
    end

    context 'dex' do
      let(:config_dir) do
        Dir.mktmpdir
      end
      before(:each) do
        allow(OodPortalGenerator::Dex).to receive(:installed?).and_return(true)
        allow(OodPortalGenerator::Dex).to receive(:config_dir).and_return(config_dir)
        allow(described_class).to receive(:dex_output).and_return(dex_config)
      end

      it 'generates default dex configs' do
        allow(described_class).to receive(:context).and_return({ dex: true })
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.default').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates default dex configs from nil' do
        # this simulates a config of 'dex: '. I.e., uncommented dex
        allow(described_class).to receive(:context).and_return({ dex: nil })
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.default').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates insecure default dex configs' do
        allow(described_class).to receive(:context).and_return({ dex: true })
        allow(described_class).to receive(:insecure).and_return(true)
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('output/dex/insecure_default_dex.yml').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates default dex configs with custom static password' do
        allow(described_class).to receive(:insecure).and_return(true)
        allow_any_instance_of(OodPortalGenerator::Dex).to receive(:hash_password).with('secret').and_return('$2a$12$iKLecAIN9MrxOZ0UltRb.OQOms/bgQbs5F.qCehq15oc3CvGFYzLy')
        allow(described_class).to receive(:context).and_return({
          dex: {
            static_passwords: [{
              'email'    => 'username@localhost',
              'password' => 'secret',
              'username' => 'username',
              'userID'   => 'D642A38C-402F-47AA-879B-FEC95745F5BA',
            }]
          },
        })
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.static_passwords').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'will not use a custom password if not passing insecure' do
        # same as test above, only it does not use --insecure and expects the default yaml, not static_passwords
        allow_any_instance_of(OodPortalGenerator::Dex).to receive(:hash_password).with('secret').and_return('$2a$12$iKLecAIN9MrxOZ0UltRb.OQOms/bgQbs5F.qCehq15oc3CvGFYzLy')
        allow(described_class).to receive(:context).and_return({
          dex: {
            static_passwords: [{
              'email'    => 'username@localhost',
              'password' => 'secret',
              'username' => 'username',
              'userID'   => 'D642A38C-402F-47AA-879B-FEC95745F5BA',
            }]
          },
        })
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.default').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with SSL using proxy' do
        allow(described_class).to receive(:insecure).and_return(true)
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          proxy_server: 'example-proxy.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex: true,
        })
        expected_rendered = read_fixture('ood-portal.dex-full.proxy.conf')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.full.proxy.yaml').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with SSL' do
        allow(described_class).to receive(:insecure).and_return(true)
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex: true
        })
        expected_rendered = read_fixture('ood-portal.conf.dex-full')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.full').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with Dex not behind the Apache reverse proxy' do
        allow(described_class).to receive(:insecure).and_return(true)
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex_uri: false,
          dex: true
        })
        expected_rendered = read_fixture('ood-portal.conf.dex-no-proxy')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.no-proxy').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with SSL and multiple redirect URIs' do
        allow(described_class).to receive(:insecure).and_return(true)
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex: {
            client_redirect_uris: [
              'https://localhost:4443/simplesaml/module.php/authglobus/linkback.php',
              'https://localhost:2443/oidc/callback/',
            ],
          }
        })
        expected_dex_yaml = read_fixture('dex.yaml.full-redirect-uris').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates custom dex configs' do
        with_modified_env CONFIG: 'spec/fixtures/ood_portal.dex.yaml' do
          allow(described_class).to receive(:insecure).and_return(true)
          expected_dex_yaml = read_fixture('dex.custom.yaml').gsub('/etc/ood/dex', config_dir)
          expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
          described_class.generate()
        end
      end

      it 'generates copies SSL certs' do
        certdir = Dir.mktmpdir
        cert = File.join(certdir, 'cert')
        File.open(cert, 'w') { |f| f.write("CERT") }
        key = File.join(certdir, 'key')
        File.open(key, 'w') { |f| f.write("KEY") }
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            "SSLCertificateFile #{cert}",
            "SSLCertificateKeyFile #{key}",
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex_uri: false,
          dex: true
        })
        described_class.generate()
        expect(File.exist?(File.join(config_dir, 'cert'))).to eq(true)
        expect(File.read(File.join(config_dir, 'cert'))).to eq('CERT')
        expect(File.exist?(File.join(config_dir, 'key'))).to eq(true)
        expect(File.read(File.join(config_dir, 'key'))).to eq('KEY')
      end

      # super similar to the test above, only different :context stub and expects false
      it 'generate does not copy SSL certs when dex is not enabled' do
        certdir = Dir.mktmpdir
        cert = File.join(certdir, 'cert')
        File.open(cert, 'w') { |f| f.write("CERT") }
        key = File.join(certdir, 'key')
        File.open(key, 'w') { |f| f.write("KEY") }
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            "SSLCertificateFile #{cert}",
            "SSLCertificateKeyFile #{key}",
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ]
        })
        described_class.generate()
        expect(File.exist?(File.join(config_dir, 'cert'))).to eq(false)
        expect(File.exist?(File.join(config_dir, 'key'))).to eq(false)
      end

      it 'generates LDAP dex configs with SSL' do
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
          dex: {
            connectors: [{
              type: 'ldap',
              id: 'ldap',
              name: 'LDAP',
              config: {
                host: 'ldap1.example.com:636',
                bindDN: 'cn=read,dc=example,dc=com',
                bindPW: 'secret',
                userSearch: {
                  baseDN: 'ou=People,dc=example,dc=com',
                  filter: "(objectClass=posixAccount)",
                  username: 'uid',
                  idAttr: 'uid',
                  emailAttr: 'mail',
                  nameAttr: 'gecos',
                  preferredUsernameAttr: 'uid',
                },
                groupSearch: {
                  baseDN: 'ou=Groups,dc=example,dc=com',
                  filter: "(objectClass=posixGroup)",
                  userMatchers: [{userAttr: 'dn', groupAttr: 'member'}],
                  nameAttr: 'cn',
                },
              },
            }]
          }
        })
        expected_rendered = read_fixture('ood-portal.conf.dex-ldap')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.ldap').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates Dex config using secure secret' do
        allow(described_class).to receive(:insecure).and_return(true)
        secret = Tempfile.new('secret')
        File.write(secret.path, "supersecret\n")
        allow(described_class).to receive(:context).and_return({
          dex: {
            client_secret: secret.path,
          }
        })
        expected_dex_yaml = read_fixture('dex.yaml.secret').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'raises an error when config is provided, but dex is not installed' do
        allow(OodPortalGenerator::Dex).to receive(:installed?).and_return(false)
        expect {
          allow(described_class).to receive(:context).and_return({ dex: nil })
          described_class.generate
        }.to(raise_error(ArgumentError, /You do not have dex installed/))
      end
    end
  end

  describe 'apache' do
    it 'reads from ENV' do
      with_modified_env APACHE: apache.path do
        expect(described_class.apache).to eq(apache.path)
      end
    end

    it 'should use EL apache' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(false)
      expect(described_class.apache).to eq('/etc/httpd/conf.d/ood-portal.conf')
    end

    it 'should work for Debian systems' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(true)
      expect(described_class.apache).to eq('/etc/apache2/sites-available/ood-portal.conf')
    end

    it 'handles prefix from env' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(false)
      with_modified_env PREFIX: '/foo' do
        expect(described_class.apache).to eq('/foo/etc/httpd/conf.d/ood-portal.conf')
      end
    end
  end

  describe 'save_checksum' do
    before(:each) do
      allow(File).to receive(:exist?).with('/dne.conf').and_return(true)
      allow(OodPortalGenerator).to receive(:debian?).and_return(false)
    end

    it 'saves checksum file' do
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "foo\n", "  #comment\n"])
      described_class.save_checksum('/dne.conf')
      expect(File.read(sum_path.path)).to eq("b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /etc/httpd/conf.d/ood-portal.conf\n")
    end
  end

  describe 'checksum_matches?' do
    before(:each) do
      allow(File).to receive(:exist?).with('/dne.conf').and_return(true)
      allow(described_class).to receive(:checksum_exists?).and_return(true)
    end

    it 'matches' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /etc/httpd/conf.d/ood-portal.conf\n"])
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "foo\n", "  #comment\n"])
      expect(described_class.checksum_matches?('/dne.conf')).to eq(true)
    end

    it 'matches if checksum does not exist' do
      allow(described_class).to receive(:checksum_exists?).and_return(false)
      expect(File).not_to receive(:readlines)
      expect(described_class.checksum_matches?('/dne.conf')).to eq(true)
    end

    it 'does not match' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /etc/httpd/conf.d/ood-portal.conf\n"])
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "bar\n", "  #comment\n"])
      expect(described_class.checksum_matches?('/dne.conf')).to eq(false)
    end
  end

  describe 'checksum_exists?' do
    it 'returns true' do
      allow(File).to receive(:zero?).with(sum_path.path).and_return(false)
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /etc/httpd/conf.d/ood-portal.conf\n"])
      expect(described_class.checksum_exists?).to eq(true)
    end

    it 'returns false' do
      allow(File).to receive(:zero?).with(sum_path.path).and_return(false)
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /foo/bar\n"])
      expect(described_class.checksum_exists?).to eq(true)
    end

    it 'returns false if checksum does not exist' do
      allow(File).to receive(:zero?).with(sum_path.path).and_return(false)
      allow(File).to receive(:readlines).with(sum_path.path).and_return(nil)
      sum_path.unlink
      expect(described_class.checksum_exists?).to eq(false)
    end

    it 'returns false if checksum is empty' do
      allow(File).to receive(:zero?).with(sum_path.path).and_return(true)
      expect(described_class.checksum_exists?).to eq(false)
    end
  end

  describe 'update_replace?' do
    before(:each) do
      allow(described_class).to receive(:apache).and_return(apache.path)
    end

    it 'replaces if apache config missing' do
      allow(File).to receive(:exist?).with(apache.path).and_return(false)
      expect(described_class.update_replace?).to eq(true)
    end

    it 'replaces if checksums match' do
      allow(File).to receive(:exist?).with(apache.path).and_return(true)
      allow(described_class).to receive(:checksum_matches?).with(apache.path).and_return(true)
      allow(described_class).to receive(:force).and_return(false)
      expect(described_class.update_replace?).to eq(true)
    end

    it 'does not replace if checksums do not match' do
      allow(File).to receive(:exist?).with(apache.path).and_return(true)
      allow(described_class).to receive(:checksum_matches?).with(apache.path).and_return(false)
      allow(described_class).to receive(:force).and_return(false)
      expect(described_class.update_replace?).to eq(false)
    end

    it 'does not replace if checksums do not match' do
      allow(File).to receive(:exist?).with(apache.path).and_return(true)
      allow(described_class).to receive(:checksum_matches?).with(apache.path).and_return(false)
      allow(described_class).to receive(:force).and_return(true)
      expect(described_class.update_replace?).to eq(true)
    end
  end

  describe 'apache_changed_output' do
    it 'EL apache' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(false)
      expect(described_class.apache_changed_output.join("\n")).to match(%r{httpd.service})
    end
    it 'Debian apache' do
      allow(OodPortalGenerator).to receive(:debian?).and_return(true)
      expect(described_class.apache_changed_output.join("\n")).to match(%r{apache2.service$})
    end
  end

  describe 'update_ood_portal' do
    it 'does not replace if no changes detected' do
      allow(described_class).to receive(:checksum_exists?).and_return(true)
      allow(described_class).to receive(:update_replace?).and_return(false)
      allow(described_class).to receive(:files_identical?).and_return(true)
      ret = described_class.update_ood_portal()
      expect(ret).to eq(0)
    end

    it 'does not replace if checksums do not match and cmp is true' do
      allow(described_class).to receive(:detailed_exitcodes).and_return(true)
      allow(described_class).to receive(:apache).and_return(apache.path)
      allow(described_class).to receive(:checksum_exists?).and_return(true)
      allow(described_class).to receive(:update_replace?).and_return(true)
      allow(described_class).to receive(:files_identical?).and_return(true)
      ret = described_class.update_ood_portal()
      expect(ret).to eq(0)
    end

    it 'does replace if checksums match and cmp is false' do
      allow(described_class).to receive(:detailed_exitcodes).and_return(true)
      allow(described_class).to receive(:apache).and_return(apache.path)
      allow(described_class).to receive(:checksum_exists?).and_return(true)
      allow(described_class).to receive(:update_replace?).and_return(true)
      allow(described_class).to receive(:files_identical?).and_return(false)
      allow(Process).to receive(:uid).and_return(0)
      expect(FileUtils).to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(described_class).to receive(:save_checksum).with(apache.path)
      ret = described_class.update_ood_portal()
      expect(ret).to eq(3)
    end

    it 'creates backup of Apache when replacing' do
      allow(described_class).to receive(:detailed_exitcodes).and_return(true)
      allow(described_class).to receive(:apache).and_return(apache.path)
      allow(described_class).to receive(:apache_bak).and_return("#{apache.path}.bak")
      allow(described_class).to receive(:checksum_exists?).and_return(true)
      allow(described_class).to receive(:update_replace?).and_return(true)
      allow(described_class).to receive(:files_identical?).and_return(false)
      allow(Process).to receive(:uid).and_return(0)
      expect(FileUtils).to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(described_class).to receive(:save_checksum).with(apache.path)
      ret = described_class.update_ood_portal()
      expect(ret).to eq(3)
      expect(File.exist?("#{apache.path}.bak")).to eq(true)
    end

    it 'does not replace if checksums do not match and cmp is false' do
      allow(described_class).to receive(:detailed_exitcodes).and_return(true)
      allow(described_class).to receive(:apache).and_return(apache.path)
      allow(described_class).to receive(:checksum_exists?).and_return(true)
      allow(described_class).to receive(:update_replace?).and_return(false)
      allow(described_class).to receive(:files_identical?).and_return(false)
      allow(Process).to receive(:uid).and_return(0)
      expect(FileUtils).to receive(:chown).with('root', 'apache', "#{apache.path}.new", verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, "#{apache.path}.new", verbose: true)
      ret = described_class.update_ood_portal()
      expect(ret).to eq(4)
      expect(File.exist?("#{apache.path}.new")).to eq(true)
    end
  end
end
