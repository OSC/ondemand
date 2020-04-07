require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__
require 'tempfile'

describe OodPortalGenerator::Dex do
  describe 'installed?' do
    it 'returns true' do
      allow(File).to receive(:directory?).with('/etc/ood/dex').and_return(true)
      allow(File).to receive(:executable?).with('/usr/local/bin/ondemand-dex').and_return(true)
      expect(described_class.installed?).to eq(true)
    end
    it 'returns false if no executable' do
      allow(File).to receive(:directory?).with('/etc/ood/dex').and_return(true)
      allow(File).to receive(:executable?).with('/usr/local/bin/ondemand-dex').and_return(false)
      expect(described_class.installed?).to eq(false)
    end
    it 'returns false if no directry' do
      allow(File).to receive(:directory?).with('/etc/ood/dex').and_return(false)
      allow(File).to receive(:executable?).with('/usr/local/bin/ondemand-dex').and_return(true)
      expect(described_class.installed?).to eq(false)
    end
  end
end
