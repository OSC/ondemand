require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__
require 'tempfile'

describe OodPortalGenerator do
  let(:os_release_file) do
    Tempfile.new('os-release')
  end

  after(:each) do
    os_release_file.unlink
  end

  describe 'os_release_file' do
    it 'returns nil if does not exist' do
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(nil)
      expect(described_class.os_release_file).to be_nil
    end

    it 'returns path if exists' do
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
      expect(described_class.os_release_file).to eq('/etc/os-release')
    end
  end

  describe 'scl_apache?' do
    it 'returns true if /etc/os-release does not exist' do
      allow(described_class).to receive(:os_release_file).and_return(nil)
      expect(described_class.scl_apache?).to eq(true)
    end

    it 'returns true if RHEL7' do
      os_release = <<-EOS
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="7.7"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(true)
    end

    it 'returns true if CentOS7' do
      os_release = <<-EOS
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(true)
    end

    it 'returns false if RHEL8' do
      os_release = <<-EOS
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.0"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end

    it 'returns true if CentOS8' do
      os_release = <<-EOS
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="8"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end
  end
end