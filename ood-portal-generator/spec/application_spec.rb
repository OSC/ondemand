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

  before(:each) do
    stub_const('ARGV', [])
    allow(described_class).to receive(:sum_path).and_return(sum_path.path)
    allow(described_class).to receive(:dex_config).and_return(dex_config.path)
    allow(OodPortalGenerator).to receive(:fqdn).and_return('example.com')
  end

  after(:each) do
    sum_path.unlink
    apache.unlink
  end

  describe 'generate' do
    it 'runs generate' do
      expect { described_class.generate() }.to output(/VirtualHost/).to_stdout
    end

    it 'generates default template' do
      expected_rendered = read_fixture('ood-portal.conf.default')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end

    it 'generates without maintenance' do
      allow(described_class).to receive(:context).and_return({use_maintenance: false})
      expected_rendered = read_fixture('ood-portal.conf.nomaint')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end

    it 'generates maintenance template with IP whitelist' do
      allow(described_class).to receive(:context).and_return({maintenance_ip_whitelist: ['192.168.1..*', '10.0.0..*']})
      expected_rendered = read_fixture('ood-portal.conf.maint_with_ips')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end
    it 'generates maintenance template with IP whitelist already escaped' do
      allow(described_class).to receive(:context).and_return({maintenance_ip_whitelist: ['192\.168\.1\..*', '10\.0\.0\..*']})
      expected_rendered = read_fixture('ood-portal.conf.maint_with_ips')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
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
      }
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
      }
      allow(described_class).to receive(:context).and_return(config)
      expected_rendered = read_fixture('ood-portal.conf.oidc-ssl')
      expect(described_class.output).to receive(:write).with(expected_rendered)
      described_class.generate()
    end

    context 'dex' do
      let(:config_dir) do
        Dir.mktmpdir
      end
      before(:each) do
        allow(OodPortalGenerator::Dex).to receive(:installed?).and_return(true)
        allow(OodPortalGenerator::Dex).to receive(:config_dir).and_return(config_dir)
        allow_any_instance_of(OodPortalGenerator::Dex).to receive(:enabled?).and_return(true)
        user = Etc.getlogin
        gid = Etc.getpwnam(user).gid
        group = Etc.getgrgid(gid).name
        allow(OodPortalGenerator).to receive(:dex_user).and_return(user)
        allow(OodPortalGenerator).to receive(:dex_group).and_return(group)
        allow(described_class).to receive(:dex_output).and_return(dex_config)
      end

      it 'generates default dex configs' do
        expected_rendered = read_fixture('ood-portal.conf.dex')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.default').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with SSL' do
        allow(described_class).to receive(:context).and_return({
          servername: 'example.com',
          port: '443',
          ssl: [
            'SSLCertificateFile /etc/pki/tls/certs/example.com.crt',
            'SSLCertificateKeyFile /etc/pki/tls/private/example.com.key',
            'SSLCertificateChainFile /etc/pki/tls/certs/example.com-interm.crt',
          ],
        })
        expected_rendered = read_fixture('ood-portal.conf.dex-full')
        expect(described_class.output).to receive(:write).with(expected_rendered)
        expected_dex_yaml = read_fixture('dex.yaml.full').gsub('/etc/ood/dex', config_dir)
        expect(described_class.dex_output).to receive(:write).with(expected_dex_yaml)
        described_class.generate()
      end

      it 'generates full dex configs with SSL and multiple redirect URIs' do
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
        })
        described_class.generate()
        expect(File.exists?(File.join(config_dir, 'cert'))).to eq(true)
        expect(File.read(File.join(config_dir, 'cert'))).to eq('CERT')
        expect(File.exists?(File.join(config_dir, 'key'))).to eq(true)
        expect(File.read(File.join(config_dir, 'key'))).to eq('KEY')
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
    end
  end

  describe 'apache' do
    it 'reads from ENV' do
      with_modified_env APACHE: apache.path do
        expect(described_class.apache).to eq(apache.path)
      end
    end

    it 'should use SCL apache' do
      allow(OodPortalGenerator).to receive(:scl_apache?).and_return(true)
      expect(described_class.apache).to eq('/opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf')
    end

    it 'should not use SCL apache' do
      allow(OodPortalGenerator).to receive(:scl_apache?).and_return(false)
      expect(described_class.apache).to eq('/etc/httpd/conf.d/ood-portal.conf')
    end
  end

  describe 'save_checksum' do
    before(:each) do
      allow(File).to receive(:exist?).with('/dne.conf').and_return(true)
      allow(OodPortalGenerator).to receive(:scl_apache?).and_return(true)
    end

    it 'saves checksum file' do
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "foo\n", "  #comment\n"])
      described_class.save_checksum('/dne.conf')
      expect(File.read(sum_path.path)).to eq("b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf\n")
    end
  end

  describe 'checksum_matches?' do
    before(:each) do
      allow(File).to receive(:exist?).with('/dne.conf').and_return(true)
    end

    it 'matches' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf\n"])
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "foo\n", "  #comment\n"])
      expect(described_class.checksum_matches?('/dne.conf')).to eq(true)
    end

    it 'does not match' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf\n"])
      allow(File).to receive(:readlines).with('/dne.conf').and_return(["# comment\n", "bar\n", "  #comment\n"])
      expect(described_class.checksum_matches?('/dne.conf')).to eq(false)
    end
  end

  describe 'checksum_exists?' do
    it 'returns true' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /opt/rh/httpd24/root/etc/httpd/conf.d/ood-portal.conf\n"])
      expect(described_class.checksum_exists?).to eq(true)
    end

    it 'returns false' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(["b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c /foo/bar\n"])
      expect(described_class.checksum_exists?).to eq(true)
    end

    it 'returns false if checksum does not exist' do
      allow(File).to receive(:readlines).with(sum_path.path).and_return(nil)
      sum_path.unlink
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
      ret = described_class.update_ood_portal()
      expect(ret).to eq(4)
      expect(File.exist?("#{apache.path}.new")).to eq(true)
    end
  end
end
