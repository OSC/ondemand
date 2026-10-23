# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'socket'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:user) { 'socket_recovery_user' }
  let(:directory) { Dir.mktmpdir('socket-recovery-') }
  let(:runtime_root) { File.join(directory, 'run', user) }
  let(:pid_path) { File.join(runtime_root, 'passenger.pid') }
  let(:socket_path) { File.join(runtime_root, 'passenger.sock') }
  let(:config_path) { File.join(directory, "#{user}.conf") }
  let(:secret_path) { File.join(directory, "#{user}.secret") }
  let(:generator) { described_class.new }
  let(:socket) { instance_double(Socket, close: nil) }

  before do
    allow(NginxStage::PunProcess).to receive(:state) do |pid_file:, **|
      pid_file.running_process? ? :matching : :dead
    end
    allow(NginxStage).to receive(:pending_cleanup_users).and_return([])
    FileUtils.mkdir_p(runtime_root)
    File.write(pid_path, '12345')
    File.write(socket_path, 'socket inode stand-in')
    File.write(config_path, 'configuration')
    File.write(secret_path, 'secret')
    allow(NginxStage).to receive_messages(active_users: [user], inactive_users: [])
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.pid')
    end
    allow(NginxStage).to receive(:pun_socket_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.sock')
    end
    allow(NginxStage).to receive(:pun_config_path) do |user:|
      File.join(directory, "#{user}.conf")
    end
    allow(NginxStage).to receive(:pun_secret_key_base_path).with(user: user).and_return(secret_path)
    allow(Process).to receive(:getpgid).with(12_345).and_raise(Errno::ESRCH)
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: anything, signal: :stop).and_raise(Errno::ESRCH)
    # Socket syscalls are unavailable in the test environment. Keep real file
    # identity/deletion and flock behavior; simulate only type and connection.
    allow(File).to receive(:lstat).and_wrap_original do |original, path|
      stat = original.call(path)
      path.to_s == socket_path ? instance_double(File::Stat, socket?: true, dev: stat.dev, ino: stat.ino) : stat
    end
    allow(Socket).to receive(:new).with(Socket::AF_UNIX, Socket::SOCK_STREAM, 0).and_return(socket)
    allow(socket).to receive(:connect_nonblock).and_raise(Errno::ECONNREFUSED)
    allow(generator).to receive(:puts)
  end

  after do
    allow(File).to receive(:unlink).and_call_original
    allow(File).to receive(:lstat).and_call_original
    FileUtils.remove_entry(directory)
  end

  [:dead_pid, :invalid_pid, :disabled_dead_pid, :pending_without_pid].each do |state|
    context "with #{state}" do
      before do
        File.write(pid_path, '0') if state == :invalid_pid
        if [:disabled_dead_pid, :pending_without_pid].include?(state)
          allow(NginxStage).to receive_messages(active_users: [], inactive_users: [user])
          allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
        end
        if state == :pending_without_pid
          File.unlink(pid_path)
          File.write(NginxStage.pun_cleanup_path(user: user), '', perm: 0o600)
        end
      end

      it 'removes the refused socket under the lock and allows a subsequent startup' do
        allow(File).to receive(:unlink).and_wrap_original do |original, path|
          if path.to_s == socket_path
            File.open("#{config_path}.lock", File::RDWR) do |competitor|
              expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
            end
          end
          original.call(path)
        end
        allow(Open3).to receive(:capture2e).and_raise('unexpected nginx execution during recovery')
        expect { generator.invoke }.to output([:dead_pid, :invalid_pid].include?(state) ? /removed/i : '').to_stderr
        expect(File.exist?(pid_path)).to be(false)
        expect(File.exist?(socket_path)).to be(false)
        if [:dead_pid, :invalid_pid].include?(state)
          expect(File.read(secret_path)).to eq('secret')
        else
          expect(File.exist?(secret_path)).to be(false)
          expect(File.exist?(NginxStage.pun_cleanup_path(user: user))).to be(false)
        end
        allow(NginxStage).to receive(:clean_nginx_env)
        allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
        status = instance_double(Process::Status, success?: true)
        allow(Open3).to receive(:capture2e).and_return(['', status])
        expect(Open3).to receive(:capture2e).once
        expect(generator.send(:run_nginx, user: user)).to eq(['', status])
      end

      [0, :wait_writable, Errno::EACCES].each do |result|
        it "preserves PID, socket and secret for connection result #{result}" do
          if result.is_a?(Class)
            allow(socket).to receive(:connect_nonblock).and_raise(result)
          else
            allow(socket).to receive(:connect_nonblock).and_return(result)
          end
          expect(FileUtils).not_to receive(:rm)
          expect(Open3).not_to receive(:capture2e)
          expect { generator.invoke }.to output(/socket path still exists/).to_stderr
          expect(File.exist?(socket_path)).to be(true)
          expect(File.exist?(pid_path)).to eq(state != :pending_without_pid)
          expect(File.read(secret_path)).to eq('secret')
        end
      end
    end
  end

  it 'does not probe or delete anything in a dry run' do
    expect(Socket).not_to receive(:new)
    dry_run = described_class.new(skip_nginx: true)
    expect { dry_run.invoke }.to output("#{user}\n").to_stdout
    expect(File.exist?(pid_path)).to be(true)
    expect(File.exist?(socket_path)).to be(true)
  end

  it 'preserves a symlinked invalid PID even beside a stale socket' do
    target = File.join(directory, 'target')
    File.write(target, '0')
    File.unlink(pid_path)
    File.symlink(target, pid_path)
    expect(FileUtils).not_to receive(:rm)
    expect { generator.invoke }.to output(/PID is a symlink/).to_stderr
    expect(File.symlink?(pid_path)).to be(true)
    expect(File.exist?(socket_path)).to be(true)
  end

  it 'retains the PID and secret if stale socket deletion is denied' do
    allow(File).to receive(:unlink).and_call_original
    allow(File).to receive(:unlink).with(socket_path).and_raise(Errno::EACCES)
    expect { generator.invoke }.to output(/Permission denied/).to_stderr
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(secret_path)).to eq('secret')
    expect(File.exist?(socket_path)).to be(true)
  end

  it 'rediscovers a timed-out cleanup after shutdown removed the PID but left a stale socket' do
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching)
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_call_original
    allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: anything, signal: :stop).and_return(1)
    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: anything, signal: :stop).once
    allow(generator).to receive(:wait_for_pun_shutdown) do
      File.unlink(pid_path)
      raise NginxStage::Error, 'shutdown timed out'
    end
    expect { generator.invoke }.to output(/shutdown timed out/).to_stderr
    expect(File.exist?(NginxStage.pun_cleanup_path(user: user))).to be(true)
    expect(NginxStage.inactive_users).to eq([user])

    retry_cleanup = described_class.new
    allow(retry_cleanup).to receive(:puts)
    expect { retry_cleanup.invoke }.not_to output.to_stderr

    expect(File.exist?(socket_path)).to be(false)
    expect(File.exist?(secret_path)).to be(false)
    expect(File.exist?(config_path)).to be(false)
    expect(File.exist?(runtime_root)).to be(false)
    expect(NginxStage.inactive_users).to eq([])
  end
end
