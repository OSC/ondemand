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
      os_release = <<~EOS
        ID="rhel"
        ID_LIKE="fedora"
        VERSION_ID="7.7"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(true)
    end

    it 'returns true if CentOS7' do
      os_release = <<~EOS
        ID="centos"
        ID_LIKE="rhel fedora"
        VERSION_ID="7"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(true)
    end

    it 'returns false if RHEL8' do
      os_release = <<~EOS
        ID="rhel"
        ID_LIKE="fedora"
        VERSION_ID="8.0"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end

    it 'returns false if CentOS8' do
      os_release = <<~EOS
        ID="centos"
        ID_LIKE="rhel fedora"
        VERSION_ID="8"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end

    it 'returns false if RHEL9' do
      os_release = <<~EOS
        ID="rhel"
        ID_LIKE="fedora"
        VERSION_ID="9.0"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end

    it 'returns false for Ubuntu 20.04' do
      os_release = <<~EOS
        ID=ubuntu
        ID_LIKE=debian
        VERSION_ID="20.04"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.scl_apache?).to eq(false)
    end
  end

  describe 'debian?' do
    it 'returns false if CentOS8' do
      os_release = <<~EOS
        ID="centos"
        ID_LIKE="rhel fedora"
        VERSION_ID="8"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.debian?).to eq(false)
    end

    it 'returns true for Ubuntu 20.04' do
      os_release = <<~EOS
        ID=ubuntu
        ID_LIKE=debian
        VERSION_ID="20.04"
      EOS
      File.write(os_release_file.path, os_release)
      allow(described_class).to receive(:os_release_file).and_return(os_release_file.path)
      expect(described_class.debian?).to eq(true)
    end
  end

  describe 'apache_group' do
    let(:getgrnam) { Struct.new(:name, keyword_init: true) }
    it 'returns apache' do
      group = getgrnam.new(name: 'apache')
      allow(Etc).to receive(:getgrnam).with('apache').and_return(group)
      expect(described_class.apache_group).to eq('apache')
    end
    it 'returns www-data' do
      group = getgrnam.new(name: 'www-data')
      allow(Etc).to receive(:getgrnam).with('apache').and_raise(ArgumentError)
      allow(Etc).to receive(:getgrnam).with('www-data').and_return(group)
      expect(described_class.apache_group).to eq('www-data')
    end
  end
end