# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:directory) { Dir.mktmpdir('socket-only-cleanup') }
  let(:user) { 'socket_user' }
  let(:runtime) { File.join(directory, 'run', user) }
  let(:pid_path) { File.join(runtime, 'passenger.pid') }
  let(:socket_path) { File.join(runtime, 'passenger.sock') }
  let(:config_path) { File.join(directory, "#{user}.conf") }
  let(:secret_path) { File.join(directory, "#{user}.secret") }
  let(:account) { instance_double(NginxStage::User, to_s: user) }
  let(:connection) { instance_double(Socket, close: nil) }

  before do
    FileUtils.mkdir_p(runtime)
    File.write(socket_path, 'socket entry')
    File.write(config_path, 'configuration')
    File.write(secret_path, 'secret')
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.pid')
    end
    allow(NginxStage).to receive(:pun_socket_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.sock')
    end
    allow(NginxStage).to receive(:pun_config_path) do |user:|
      File.join(directory, "#{user}.conf")
    end
    allow(NginxStage).to receive(:pun_secret_key_base_path).with(user: account).and_return(secret_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).with(user: user).and_return(secret_path)
    allow(NginxStage::User).to receive(:new).with(user).and_return(account)
    allow(Syslog::Logger).to receive(:new).and_return(instance_double(Syslog::Logger, error: nil))
    # Keep real discovery, inode checks and locking; simulate the unavailable Unix socket syscalls.
    allow(File).to receive(:lstat).and_wrap_original do |original, path|
      stat = original.call(path)
      if path.to_s == socket_path && stat.file?
        instance_double(File::Stat, socket?: true, dev: stat.dev, ino: stat.ino)
      else
        stat
      end
    end
    allow(Socket).to receive(:new).with(Socket::AF_UNIX, Socket::SOCK_STREAM, 0).and_return(connection)
    allow(connection).to receive(:connect_nonblock).and_raise(Errno::ECONNREFUSED)
    allow(File).to receive(:unlink).and_call_original
  end

  after do
    allow(File).to receive(:lstat).and_call_original
    FileUtils.remove_entry(directory)
  end

  [false, true].each do |force|
    it "discovers and recovers a stale socket without a PID, force=#{force}" do
      cleaner = described_class.new(force: force, user: user)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)
      expect(File).to receive(:unlink).with(socket_path).and_wrap_original do |original, path|
        File.open("#{config_path}.lock", File::RDWR) do |competitor|
          expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
        end
        original.call(path)
      end

      expect { cleaner.invoke }.to output(/stale socket file removed/).to_stderr
      expect(File.exist?(socket_path)).to be(false)
      expect(File.exist?(pid_path)).to be(false)
      expect(File.read(config_path)).to eq('configuration')
      expect(File.read(secret_path)).to eq('secret')
      expect(NginxStage::Generator.new.send(:pun_running?, user: user)).to be(false)
    end

    [0, :wait_writable].each do |result|
      it "preserves socket-only state for probe result #{result}, force=#{force}" do
        allow(connection).to receive(:connect_nonblock).and_return(result)
        expect(NginxStage::PunProcess).not_to receive(:signal)
        original_inode = File.lstat(socket_path).ino

        expect { described_class.new(force: force).invoke }.to output(/live or uncertain/).to_stderr
        expect(File.read(socket_path)).to eq('socket entry')
        expect(File.lstat(socket_path).ino).to eq(original_inode)
        expect(File.read(config_path)).to eq('configuration')
        expect(File.read(secret_path)).to eq('secret')
      end
    end
  end

  it 'does not lock, probe or alter an unselected socket-only account' do
    cleaner = described_class.new(user: 'different_user')
    expect(cleaner).not_to receive(:with_pun_lifecycle_lock)
    expect(Socket).not_to receive(:new)

    cleaner.invoke

    expect(File.read(socket_path)).to eq('socket entry')
    expect(File.exist?("#{config_path}.lock")).to be(false)
  end

  [:file, :symlink].each do |kind|
    it "preserves an unidentified #{kind} in the socket path without probing" do
      if kind == :symlink
        File.unlink(socket_path)
        File.symlink(File.join(directory, 'missing-target'), socket_path)
      end
      allow(File).to receive(:lstat).and_call_original
      expect(Socket).not_to receive(:new)

      expect { described_class.new(force: true).invoke }.to output(/live or uncertain/).to_stderr
      expect(File.exist?(socket_path) || File.symlink?(socket_path)).to be(true)
      expect(File.read(config_path)).to eq('configuration')
    end
  end

  it 'does not probe or delete socket-only state during a cleanup dry run' do
    expect(Socket).not_to receive(:new)
    expect(NginxStage::PunProcess).not_to receive(:signal)

    expect { described_class.new(skip_nginx: true).invoke }.to output("#{user}\n").to_stdout
    expect(File.read(socket_path)).to eq('socket entry')
    expect(File.read(config_path)).to eq('configuration')
  end

  context 'when the account is disabled' do
    before do
      allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
    end

    it 'discovers socket-only state and completes safe disabled-account cleanup' do
      expect(NginxStage::PunProcess).not_to receive(:signal)

      expect { described_class.new.invoke }.to output("#{user} (disabled)\n").to_stdout
      expect(File.exist?(runtime)).to be(false)
      expect(File.exist?(config_path)).to be(false)
      expect(File.exist?(secret_path)).to be(false)
      expect(File.exist?(NginxStage.pun_cleanup_path(user: user))).to be(false)
      expect(File.exist?("#{config_path}.lock")).to be(true)
    end

    [0, :wait_writable].each do |result|
      it "retains its retry record and metadata for probe result #{result}" do
        allow(connection).to receive(:connect_nonblock).and_return(result)
        expect(NginxStage::PunProcess).not_to receive(:signal)

        expect { described_class.new(force: true).invoke }
          .to output("#{user} (disabled)\n").to_stdout.and output(/PID or socket path still exists/).to_stderr
        expect(File.read(socket_path)).to eq('socket entry')
        expect(File.read(config_path)).to eq('configuration')
        expect(File.read(secret_path)).to eq('secret')
        expect(File.exist?(NginxStage.pun_cleanup_path(user: user))).to be(true)
      end
    end
  end
end
