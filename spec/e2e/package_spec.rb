# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand installed with packages' do
  describe package('ondemand') do
    it { is_expected.to be_installed }
  end

  describe file(host_portal_config) do
    it { is_expected.to exist }
    it { is_expected.to be_owned_by('root') }
    it { is_expected.to be_grouped_into(apache_user) }
    it { is_expected.to be_mode('0640') }
  end

  describe file('/etc/apache2/sites-enabled/ood-portal.conf'), if: host_inventory['platform'] == 'ubuntu' do
    it { is_expected.to be_linked_to('../sites-available/ood-portal.conf') }
  end

  describe file('/etc/sudoers.d/ood') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to include "Defaults:#{apache_user}" }
  end

  describe file('/etc/cron.d/ood') do
    it { is_expected.to be_file }
  end

  describe file('/etc/logrotate.d/ood') do
    it { is_expected.to be_file }
    its(:content) { is_expected.to include '/var/log/ondemand-nginx/*/access.log /var/log/ondemand-nginx/*/error.log' }
  end

  describe file("/etc/systemd/system/#{apache_service}.service.d/ood.conf") do
    it { is_expected.to be_file }
  end

  describe file("/etc/systemd/system/#{apache_service}.service.d/ood-portal.conf") do
    it { is_expected.to be_file }
    its(:content) { is_expected.to include "ExecReload=#{apache_reload}" }
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
