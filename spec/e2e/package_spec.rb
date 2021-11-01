# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand installed with packages' do
  describe package('ondemand') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/sudoers.d/ood') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{Defaults:#{apache_user}} }
  end

  describe file('/etc/cron.d/ood') do
    it { is_expected.to be_file }
  end

  describe file('/etc/logrotate.d/ood') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{/var/log/ondemand-nginx/\*/access.log /var/log/ondemand-nginx/\*/error.log} }
  end

  describe file("/etc/systemd/system/#{apache_service}.service.d/ood.conf") do
    it { is_expected.to be_file }
  end

  describe file("/etc/systemd/system/#{apache_service}.service.d/ood-portal.conf") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{ExecReload=#{apache_reload}} }
  end

  describe file('/usr/lib/tmpfiles.d/ondemand-nginx.conf') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to match %r{^d /run/ondemand-nginx} }
    its(:content) { is_expected.to match %r{^Z /run/ondemand-nginx} }
  end

  describe file('/var/www/ood/public/logo.png') do
    it { is_expected.to be_file }
  end

  describe file('/var/www/ood/public/favicon.ico') do
    it { is_expected.to be_file }
  end
end
