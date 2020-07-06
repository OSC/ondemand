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
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.exist?(apache.path)).to eq(true)
      expect(File.exist?(sum.path)).to eq(true)
    end
  end

  it 'updates ood-portal.conf' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('ood_portal.yaml.port'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.read(apache.path)).to match(/^<VirtualHost \*:8080>$/)
    end
  end

  it 'does not update ood-portal.conf if checksum differs' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('ood_portal.yaml.port'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.not-default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', [])
      expect(File.read(apache.path)).to match(/^<VirtualHost \*:80>$/)
    end
  end

  it 'no changes to ood-portal.conf and exits 0' do
    with_modified_env APACHE: apache.path, SUM: sum.path  do
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
    end
  end

  it 'updates ood-portal.conf exits 3' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('ood_portal.yaml.port'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(3)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      expect(File.read(apache.path)).to match(/^<VirtualHost \*:8080>$/)
    end
  end

  it 'does not update ood-portal.conf if checksum differs exits 4' do
    with_modified_env APACHE: apache.path, SUM: sum.path, CONFIG: config.path do
      File.write(config.path, read_fixture('ood_portal.yaml.port'))
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.not-default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(4)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      expect(File.read(apache.path)).to match(/^<VirtualHost \*:80>$/)
    end
  end

  context 'dex' do
    before(:each) do
      allow(OodPortalGenerator).to receive(:fqdn).and_return('example.com')
      allow(OodPortalGenerator::Dex).to receive(:installed?).and_return(true)
      allow_any_instance_of(OodPortalGenerator::Dex).to receive(:enabled?).and_return(true)
      user = Etc.getlogin
      gid = Etc.getpwnam(user).gid
      group = Etc.getgrgid(gid).name
      allow(OodPortalGenerator).to receive(:dex_user).and_return(user)
      allow(OodPortalGenerator).to receive(:dex_group).and_return(group)
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
