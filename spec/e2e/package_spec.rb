# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand installed with packages' do # rubocop:disable RSpec/DescribeClass
  describe package('ondemand') do
    it { is_expected.to be_installed }
  end

  # rubocop:disable RSpec/RepeatedExampleGroupBody
  # rubocop:disable RSpec/RepeatedDescription
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
  # rubocop:enable RSpec/RepeatedExampleGroupBody
  # rubocop:enable RSpec/RepeatedDescription
end
