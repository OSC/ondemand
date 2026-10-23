# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:directory) { Dir.mktmpdir('clean-group-') }
  let(:user) { 'spec' }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_raise(ArgumentError, 'group lookup unavailable')
    allow(NginxStage).to receive_messages(active_users: [], inactive_users: [user], pending_cleanup_users: [],
                                          pun_config_path: File.join(directory, 'pun.conf'),
                                          pun_pid_path: File.join(directory, 'pun.pid'),
                                          pun_socket_path: File.join(directory, 'pun.sock'),
                                          pun_secret_key_base_path: File.join(directory, 'pun.secret'))
    ['pid', 'sock', 'conf', 'secret'].each { |suffix| File.write(File.join(directory, "pun.#{suffix}"), 'preserve') }
  end

  after { FileUtils.remove_entry(directory) }

  [false, true].each do |pending|
    it "preserves a confirmed account with failed group lookup, pending=#{pending}" do
      record = File.join(directory, 'pun.conf.cleanup_pending')
      File.write(record, '', perm: 0o600) if pending
      expect(NginxStage::PunProcess).not_to receive(:state)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(FileUtils).not_to receive(:rm)
      expect { described_class.new(force: true).invoke }.to output(/Account spec still exists/).to_stderr
      ['pid', 'sock', 'conf', 'secret'].each do |suffix|
        expect(File.read(File.join(directory, "pun.#{suffix}"))).to eq('preserve')
      end
      expect(File.exist?(record)).to eq(pending)
    end
  end

  context 'with a numeric UID lookup' do
    let(:user) { '1000' }

    it 'preserves an account resolved by UID when primary-group lookup fails' do
      allow(Etc).to receive(:getpwuid).with(1000).and_return(Etc.getpwnam(user))
      expect(NginxStage::PunProcess).not_to receive(:state)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect { described_class.new.invoke }.to output(/Account 1000 still exists/).to_stderr
      expect(File.read(File.join(directory, 'pun.conf'))).to eq('preserve')
      expect(File.exist?(File.join(directory, 'pun.conf.cleanup_pending'))).to be(false)
    end
  end
end
