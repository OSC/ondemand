require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__
require 'etc'
require 'tempfile'

describe 'update_ood_portal' do
  let(:sum) do
    Tempfile.new('sum')
  end

  let(:apache) do
    Tempfile.new('apache')
  end

  let(:config) do
    Tempfile.new('config')
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

  before(:each) do
    allow(Process).to receive(:uid).and_return(0)
    allow(OodPortalGenerator).to receive(:apache_group).and_return('apache')
    allow(OodPortalGenerator).to receive(:debian?).and_return(false)
    allow(OodPortalGenerator).to receive(:fqdn).and_return('example.com')
    allow(Socket).to receive(:ip_address_list).and_return([Addrinfo.ip("8.8.8.8")])
  end

  after(:each) do
    sum.unlink
    apache.unlink
    config.unlink
    dex_config.unlink
  end

  it 'creates ood-portal.conf and exits 0' do
    with_modified_env APACHE: apache.path, SUM: sum.path  do
      File.delete(sum.path)
      File.delete(apache.path)
      expect(FileUtils).to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.exist?(apache.path)).to eq(true)
      expect(File.exist?(sum.path)).to eq(true)
    end
  end

  it 'updates ood-portal.conf' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('input/auth.yml'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(FileUtils).to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.read(apache.path)).to eq(read_fixture('output/auth.conf'))
    end
  end

  it 'does not update ood-portal.conf if checksum differs' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('input/auth.yml'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.not-default'))
      expect(FileUtils).not_to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).not_to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.read(apache.path)).to eq(read_fixture('ood-portal.conf.default'))
    end
  end

  it 'no changes to ood-portal.conf and exits 0' do
    with_modified_env APACHE: apache.path, SUM: sum.path  do
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(FileUtils).not_to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).not_to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
    end
  end

  it 'updates ood-portal.conf exits 3' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('input/auth.yml'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(FileUtils).to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(3)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      expect(File.read(apache.path)).to eq(read_fixture('output/auth.conf'))
    end
  end

  it 'does not update ood-portal.conf if checksum differs exits 4' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('input/auth.yml'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.not-default'))
      expect(FileUtils).not_to receive(:chown).with('root', 'apache', apache.path, verbose: true)
      expect(FileUtils).not_to receive(:chmod).with(0640, apache.path, verbose: true)
      expect(OodPortalGenerator::Application).to receive(:exit!).with(4)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      expect(File.read(apache.path)).to eq(read_fixture('ood-portal.conf.default'))
    end
  end

  context 'dex' do
    before(:each) do
      allow(OodPortalGenerator::Dex).to receive(:installed?).and_return(true)
      allow(OodPortalGenerator::Application).to receive(:context).and_return({ dex: true })
      allow(OodPortalGenerator).to receive(:dex_user).and_return(user)
      allow(OodPortalGenerator).to receive(:dex_group).and_return(group)
      allow_any_instance_of(OodPortalGenerator::Dex).to receive(:default_secret_path).and_return(dex_secret_path.path)
      allow(SecureRandom).to receive(:uuid).and_return('83bc78b7-6f5e-4010-9d80-22f328aa6550')
    end

    it 'does not replace dex config' do
      with_modified_env APACHE: apache.path, SUM: sum.path, DEX_CONFIG: dex_config.path  do
        File.write(apache.path, read_fixture('ood-portal.conf.dex'))
        File.write(sum.path, read_fixture('sum.dex'))
        File.write(dex_config.path, read_fixture('dex.yaml.default'))
        expect(FileUtils).not_to receive(:mv)
        expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
        OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      end
    end

    it 'replaces dex config' do
      with_modified_env APACHE: apache.path, SUM: sum.path, DEX_CONFIG: dex_config.path  do
        File.write(apache.path, read_fixture('ood-portal.conf.dex'))
        File.write(sum.path, read_fixture('sum.dex'))
        File.write(dex_config.path, read_fixture('dex.yaml.full'))
        expect(FileUtils).to receive(:mv).with(dex_config.path, anything, verbose: true)
        expect(FileUtils).to receive(:mv).with(anything, dex_config.path, verbose: true)
        expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
        OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      end
    end
  end
end
