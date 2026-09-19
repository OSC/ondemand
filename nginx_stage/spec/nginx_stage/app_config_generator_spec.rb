# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::AppConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }
  let(:generator) { described_class.new(user: test_user, sub_request: '/sys/dashboard') }
  let(:socket_path) { '/var/run/ondemand-nginx/spec/passenger.sock' }

  before do
    etc_stub = {
      :gid  => test_user_gid,
      :name => test_user
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
  end

  describe '#with_pun_restart_lock' do
    let(:config_path) { '/var/lib/ondemand-nginx/config/puns/spec.conf' }
    let(:lock) { double('lock') }

    before do
      allow(NginxStage).to receive(:pun_config_path).with(user: generator.user).and_return(config_path)
      allow(lock).to receive(:close)
    end

    it 'holds an exclusive lock while restarting the PUN' do
      events = []
      allow(File).to receive(:open).with(config_path, File::RDONLY).and_yield(lock)
      allow(File).to receive(:open).with(config_path, File::RDONLY).and_return(lock)
      allow(lock).to receive(:flock).with(File::LOCK_EX | File::LOCK_NB) do
        events << :locked
        0
      end

      generator.send(:with_pun_restart_lock) { events << :yielded }

      expect(events).to eq([:locked, :yielded])
    end

    it 'fails when another restart holds the lock for too long' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC)
        .and_return(0.0, described_class::PUN_RESTART_LOCK_TIMEOUT)
      allow(File).to receive(:open).with(config_path, File::RDONLY).and_return(lock))
      allow(lock).to receive(:flock).with(File::LOCK_EX | File::LOCK_NB).and_return(false)

      expect { generator.send(:with_pun_restart_lock) {} }
        .to raise_error(
          NginxStage::Error,
          "timed out waiting for another PUN restart to finish: #{config_path}"
        )
    end

    it 'reports a missing PUN config only when opening the lock fails' do
      allow(File).to receive(:open)
        .with(config_path, File::RDONLY)
        .and_raise(Errno::ENOENT, config_path)

      expect { generator.send(:with_pun_restart_lock) {} }
        .to raise_error(
          NginxStage::Error,
          "missing PUN config while acquiring restart lock: #{config_path}"
        )
    end

    it 'preserves ENOENT raised by the protected restart operation' do
      allow(File).to receive(:open).with(config_path, File::RDONLY).and_return(lock)
      allow(lock).to receive(:flock).with(File::LOCK_EX | File::LOCK_NB).and_return(0)

      expect do
        generator.send(:with_pun_restart_lock) { raise Errno::ENOENT, '/usr/sbin/nginx' }
      end.to raise_error(Errno::ENOENT, /usr\/sbin\/nginx/)

      expect(lock).to have_received(:close)
    end

  end

  describe '#wait_for_pun_socket_shutdown' do
    before do
      allow(NginxStage).to receive(:pun_socket_path).with(user: generator.user).and_return(socket_path)
    end

    it 'waits until the previous socket path is removed' do
      allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(true, false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(false)
      expect(generator).to receive(:sleep).with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once
      generator.send(:wait_for_pun_socket_shutdown)
    end

    it 'waits for a dangling symlink at the socket path to be removed' do
      allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(true, false)
      expect(generator).to receive(:sleep).with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once
      generator.send(:wait_for_pun_socket_shutdown)
    end

    it 'fails when the previous socket does not disappear before the timeout' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC)
        .and_return(0.0, described_class::PUN_SOCKET_SHUTDOWN_TIMEOUT)
      allow(File).to receive(:exist?).with(socket_path).and_return(true)

      expect { generator.send(:wait_for_pun_socket_shutdown) }
        .to raise_error(
          NginxStage::Error,
          "timed out waiting for previous PUN socket to disappear: #{socket_path}"
        )
    end
  end

  describe 'exec_nginx hook' do
    let(:hook) { generator.class.hooks[:exec_nginx] }
    let(:pid_path) { '/var/run/ondemand-nginx/spec/passenger.pid' }
    let(:status) { double(:success? => true) }

    before do
      allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
      allow(NginxStage).to receive(:pun_pid_path).with(user: generator.user).and_return(pid_path)
      allow(File).to receive(:file?).with(pid_path).and_return(true)
      allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
      allow(NginxStage).to receive(:nginx_args).with(user: generator.user, signal: :stop).and_return(['stop'])
      allow(NginxStage).to receive(:nginx_args).with(user: generator.user).and_return(['start'])
      allow(generator).to receive(:with_pun_restart_lock).and_yield
    end

    it 'waits for the old socket before starting the replacement PUN' do
      expect(generator).to receive(:with_pun_restart_lock).ordered.and_yield
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'stop').ordered.and_return(['', status])
      expect(generator).to receive(:wait_for_pun_socket_shutdown).ordered
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start').ordered.and_return(['', status])

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end

    it 'checks for a lingering socket before starting without a PUN pid file' do
      allow(File).to receive(:file?).with(pid_path).and_return(false)

      expect(Open3).not_to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'stop')
      expect(generator).to receive(:wait_for_pun_socket_shutdown).ordered
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start').ordered.and_return(['', status])

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end

    it 'does not start when a lingering socket remains without a PUN pid file' do
      allow(File).to receive(:file?).with(pid_path).and_return(false)

      expect(Open3).not_to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'stop')
      expect(generator).to receive(:wait_for_pun_socket_shutdown)
        .and_raise(NginxStage::Error, 'socket cleanup timed out')
      expect(Open3).not_to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start')

      expect { generator.instance_eval(&hook) }
        .to raise_error(NginxStage::Error, 'socket cleanup timed out')
    end

    it 'does not start the replacement PUN when socket cleanup times out' do
      allow(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'stop').and_return(['', status])
      expect(generator).to receive(:wait_for_pun_socket_shutdown)
        .and_raise(NginxStage::Error, 'socket cleanup timed out')
      expect(Open3).not_to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start')

      expect { generator.instance_eval(&hook) }
        .to raise_error(NginxStage::Error, 'socket cleanup timed out')
    end
  end
end
