# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::NginxCleanGenerator do
  let(:user) { 'spec' }
  let(:directory) { Dir.mktmpdir('nginx-clean-active-state') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'pun.conf') }
  let(:generator) { described_class.new }

  before do
    allow(NginxStage::PunProcess).to receive(:state) do |pid_file:, **|
      pid_file.running_process? ? :matching : :dead
    end
    allow(NginxStage).to receive(:pending_cleanup_users).and_return([])
    File.write(pid_path, '12345')
    File.write(config_path, 'configuration')
    allow(NginxStage).to receive_messages(active_users: [user], inactive_users: [])
    allow(NginxStage).to receive(:pun_pid_path).with(user: user).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).with(user: user).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
    allow(Process).to receive(:getpgid).with(12_345).and_raise(Errno::ESRCH)
  end

  after do
    allow(File).to receive(:unlink).and_call_original
    FileUtils.remove_entry(directory)
  end

  it 'preserves an uncertain socket when the PID disappears while waiting for the lifecycle lock' do
    File.write(socket_path, 'unidentified socket path')
    allow(generator).to receive(:with_pun_lifecycle_lock).and_wrap_original do |original, **args, &block|
      original.call(**args) do
        File.unlink(pid_path)
        block.call
      end
    end
    expect(Open3).not_to receive(:capture2e)
    expect(FileUtils).not_to receive(:rm)

    expect { generator.invoke }.to output(/PID is missing but socket path is live or uncertain/).to_stderr
    expect(File.read(socket_path)).to eq('unidentified socket path')
  end

  it 'quietly skips a PID that disappears during its read' do
    allow(NginxStage::PidFile).to receive(:new).with(pid_path) do
      File.unlink(pid_path)
      raise Errno::ENOENT
    end
    expect(Open3).not_to receive(:capture2e)
    expect(FileUtils).not_to receive(:rm)

    expect { generator.invoke }.not_to output.to_stderr
  end

  it 'removes a dead PID without a socket under the lock and does not subsequently stop nginx' do
    allow(FileUtils).to receive(:rm).and_wrap_original do |original, path|
      File.open("#{config_path}.lock", File::RDWR) do |competitor|
        expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
      end
      original.call(path)
    end
    expect(Open3).not_to receive(:capture2e)
    expect(NginxStage::SocketFile).not_to receive(:new)
    expect(generator).not_to receive(:session_count)

    expect { generator.invoke }.to output(/\Astale pid file removed: .*\n\z/).to_stderr
    expect(File.exist?(pid_path)).to be(false)
    expect(File.read(config_path)).to eq('configuration')
  end

  it 'preserves a live PID whose socket has disappeared during graceful shutdown' do
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    expect(Open3).not_to receive(:capture2e)
    expect(FileUtils).not_to receive(:rm)
    expect(generator).not_to receive(:session_count)

    expect { generator.invoke }.to output(/verified PUN master is alive without its socket/).to_stderr
    expect(File.read(pid_path)).to eq('12345')
  end

  [:socket, :ordinary_file, :dangling_symlink].each do |kind|
    [false, true].each do |force|
      it "preserves an occupied #{kind} beside a dead PID with force=#{force}" do
        if kind == :dangling_symlink
          File.symlink(File.join(directory, 'missing-target'), socket_path)
        else
          File.write(socket_path, 'unidentified socket path')
          if kind == :socket
            # Exercise socket-file handling without needing a live listener.
            allow(File).to receive(:socket?).and_call_original
            allow(File).to receive(:socket?).with(socket_path).and_return(true)
          end
        end
        generator = described_class.new(force: force)
        expect(Open3).not_to receive(:capture2e)
        expect(FileUtils).not_to receive(:rm)
        expect(NginxStage::SocketFile).not_to receive(:new)
        expect(generator).not_to receive(:session_count)

        expect { generator.invoke }.to output(/PID is gone but socket path still exists/).to_stderr
        expect(File.read(pid_path)).to eq('12345')
        expect(File.exist?(socket_path) || File.symlink?(socket_path)).to be(true)
        expect(File.read(config_path)).to eq('configuration')
      end
    end
  end

  it 'reports failed stale PID deletion without claiming removal or running nginx' do
    allow(File).to receive(:unlink).and_call_original
    allow(File).to receive(:unlink).with(pid_path).and_raise(Errno::EACCES)
    expect(Open3).not_to receive(:capture2e)

    expect { generator.invoke }
      .to output(/\AError trying to clean up active user spec: Permission denied.*\n\z/).to_stderr
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(config_path)).to eq('configuration')
    File.open("#{config_path}.lock", File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
    end
  end

  it 'does not claim removal if the dead PID file has already been unlinked' do
    allow(Process).to receive(:getpgid).with(12_345) do
      File.unlink(pid_path)
      raise Errno::ESRCH
    end
    expect(Open3).not_to receive(:capture2e)

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'reports a dead PID without modifying it for --skip-nginx' do
    generator = described_class.new(skip_nginx: true)
    expect(Open3).not_to receive(:capture2e)
    expect(FileUtils).not_to receive(:rm)

    expect { generator.invoke }.to output("spec\n").to_stdout
    expect(File.read(pid_path)).to eq('12345')
  end

  it 'still stops a live PUN with no sessions and waits for both paths to be removed' do
    File.write(socket_path, 'socket-path stand-in')
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(socket_path).and_return(true)
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    allow(generator).to receive(:session_count).with(user).and_return(0)
    allow(NginxStage).to receive(:clean_nginx_env).with(user: user)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args).with(user: user, signal: :stop).and_return(['stop'])
    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: user, signal: :stop) do
      File.open("#{config_path}.lock", File::RDWR) do |competitor|
        expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
      end
      File.unlink(pid_path)
      File.unlink(socket_path)
    end

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
    expect(File.exist?(pid_path)).to be(false)
    expect(File.exist?(socket_path)).to be(false)
    expect(File.read(config_path)).to eq('configuration')
  end
end
