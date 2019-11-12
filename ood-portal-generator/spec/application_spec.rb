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

  before(:each) do
    stub_const('ARGV', [])
    allow(described_class).to receive(:sum_path).and_return(sum_path.path)
  end

  after(:each) do
    sum_path.unlink
    apache.unlink
  end

  describe 'generate' do
    it 'runs generate' do
      expect { described_class.generate() }.to output(/VirtualHost/).to_stdout
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
