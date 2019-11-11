require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__
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

  after(:each) do
    sum.unlink
    apache.unlink
    config.unlink
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

  it 'not changes to ood-portal.conf and exits 0' do
    with_modified_env APACHE: apache.path, SUM: sum.path  do
      File.write(apache.path, read_fixture('ood-portal.conf.default'))
      File.write(sum.path, read_fixture('sum.default'))
      expect(OodPortalGenerator::Application).to receive(:exit!).with(0)
      OodPortalGenerator::Application.start('update_ood_portal', ['--detailed-exitcodes'])
      expect(File.exist?(apache.path)).to eq(true)
      expect(File.exist?(sum.path)).to eq(true)
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
end
