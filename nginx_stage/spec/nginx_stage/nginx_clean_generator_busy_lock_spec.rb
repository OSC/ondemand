# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'timeout'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:directory) { Dir.mktmpdir('clean-busy-') }
  let(:generator) { described_class.new(force: true) }

  def path(user, suffix)
    File.join(directory, "#{user}.#{suffix}")
  end

  before do
    allow(NginxStage).to receive(:pun_config_path) { |user:| path(user, 'conf') }
    allow(NginxStage).to receive(:pun_pid_path) { |user:| path(user, 'pid') }
    allow(NginxStage).to receive(:pun_socket_path) { |user:| path(user, 'sock') }
    allow(NginxStage).to receive(:pun_secret_key_base_path) { |user:| path(user, 'secret') }
    allow(NginxStage::PunProcess).to receive(:state).and_return(:dead)
    File.write(path('alice', 'pid'), '12345')
    File.write(path('alice', 'conf'), 'configuration')
    File.write(path('alice', 'secret'), 'secret')
    File.write(path('bob', 'pid'), '23456')
    allow(generator).to receive(:puts)
  end

  after { FileUtils.remove_entry(directory) }

  [:active, :disabled, :pending].each do |kind|
    it "preserves a busy #{kind} candidate and continues to the next user" do
      allow(NginxStage).to receive_messages(
        active_users:          kind == :active ? ['alice', 'bob'] : [],
        inactive_users:        kind == :disabled ? ['alice', 'bob'] : [],
        pending_cleanup_users: kind == :pending ? ['alice', 'bob'] : []
      )
      allow(Etc).to receive(:getpwnam).with('bob').and_raise(ArgumentError, 'account is absent')
      if kind == :pending
        File.unlink(path('alice', 'pid'))
        File.write("#{path('alice', 'conf')}.cleanup_pending", '', perm: 0o600)
        File.write("#{path('bob', 'conf')}.cleanup_pending", '', perm: 0o600)
      end
      expect(NginxStage::PunProcess).not_to receive(:signal)
      File.open("#{path('alice', 'conf')}.lock", File::RDWR | File::CREAT, 0o600) do |holder|
        holder.flock(File::LOCK_EX)
        expect { Timeout.timeout(1) { generator.invoke } }.to output(/lifecycle lock is busy/).to_stderr
        expect(holder.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
      end
      expect(File.read(path('alice', 'conf'))).to eq('configuration')
      expect(File.read(path('alice', 'secret'))).to eq('secret')
      expect(File.exist?(path('bob', 'pid'))).to be(false)
      expect(File.exist?("#{path('bob', 'conf')}.cleanup_pending")).to be(false)
      if kind == :pending
        expect(File.file?("#{path('alice', 'conf')}.cleanup_pending")).to be(true)
      else
        expect(File.read(path('alice', 'pid'))).to eq('12345')
        expect(File.exist?("#{path('alice', 'conf')}.cleanup_pending")).to be(false)
      end
    end
  end

  it 'inspects an active-user dry run without creating or acquiring a lifecycle lock' do
    cleaner = described_class.new(skip_nginx: true)
    allow(NginxStage).to receive_messages(active_users: ['alice'], inactive_users: [], pending_cleanup_users: [])
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching)
    File.write(path('alice', 'sock'), 'socket fixture')
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(path('alice', 'sock')).and_return(true)
    allow(cleaner).to receive(:session_count).and_return(0)
    expect(cleaner).not_to receive(:with_pun_lifecycle_lock)
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(NginxStage::SocketProbe).not_to receive(:new)
    expect { cleaner.invoke }.to output("alice\n").to_stdout
    expect(File.exist?("#{path('alice', 'conf')}.lock")).to be(false)
    expect(File.read(path('alice', 'pid'))).to eq('12345')
    expect(File.read(path('alice', 'sock'))).to eq('socket fixture')
  end
end
