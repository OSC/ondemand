# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'timeout'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:directory) { Dir.mktmpdir('competing-cleaners') }
  let(:user) { 'spec' }
  let(:paths) do
    { pid: File.join(directory, 'run', user, 'pun.pid'),
      socket: File.join(directory, 'run', user, 'pun.sock'),
      config: File.join(directory, 'config', 'spec.conf'), secret: File.join(directory, 'spec.secret') }
  end

  before do
    paths.each_value do |path|
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, 'preserve')
    end
    File.write(paths[:pid], '12345')
    allow(NginxStage).to receive_messages(
      pun_socket_path: paths[:socket], pun_config_path: paths[:config],
      pun_secret_key_base_path: paths[:secret], pending_cleanup_users: []
    )
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, 'pun.pid')
    end
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching)
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(paths[:socket]).and_return(true)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  [false, true].each do |disabled|
    it "skips a competing cleaner while the same flock is held, disabled=#{disabled}" do
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)
      allow(NginxStage).to receive_messages(
        active_users: disabled ? [] : [user], inactive_users: disabled ? [user] : []
      )
      allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError) if disabled
      cleaners = Array.new(2) { described_class.new(force: true) }
      cleaners.each do |cleaner|
        allow(cleaner).to receive(:session_count).with(user).and_return(0)
        allow(cleaner).to receive(:puts)
      end
      signal_entered = Queue.new
      release_signal = Queue.new
      second_attempted = Queue.new
      expect(NginxStage::PunProcess).to receive(:signal).once do
        signal_entered << true
        Timeout.timeout(5) { release_signal.pop }
        File.unlink(paths[:socket])
        File.unlink(paths[:pid])
      end
      allow(cleaners.last).to receive(:with_pun_lifecycle_lock).and_wrap_original do |original, **args, &block|
        second_attempted << true
        original.call(**args, &block)
      end
      expect(cleaners.last).to receive(:warn).with(/lifecycle lock is busy/)
      threads = []

      begin
        threads << Thread.new { cleaners.first.invoke }
        Timeout.timeout(5) { signal_entered.pop }
        threads << Thread.new { cleaners.last.invoke }
        Timeout.timeout(5) { second_attempted.pop }
        expect(threads.last.join(1)).not_to be_nil
        threads.last.value
        expect(File.exist?(paths[:pid])).to be(true)
        release_signal << true
        threads.each do |thread|
          expect(thread.join(5)).not_to be_nil
          thread.value
        end

        expect(File.exist?(paths[:pid])).to be(false)
        expect(File.exist?(paths[:socket])).to be(false)
        expect(File.exist?(paths[:config])).to eq(!disabled)
        expect(File.exist?(paths[:secret])).to eq(!disabled)
        expect(File.exist?("#{paths[:config]}.cleanup_pending")).to be(false)
        expect(File.exist?("#{paths[:config]}.lock")).to be(true)
      ensure
        threads.each { |thread| thread.kill if thread.alive? }
        threads.each(&:join)
      end
    end
  end
end
