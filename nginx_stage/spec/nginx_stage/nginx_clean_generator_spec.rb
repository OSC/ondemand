# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::NginxCleanGenerator do
  let(:generator) { described_class.new }
  let(:active_user) { instance_double(NginxStage::User, to_s: 'spec') }
  let(:pid_path) { instance_double(NginxStage::PidFile, running_process?: true) }
  let(:socket) { instance_double(NginxStage::SocketFile) }
  let(:status) { double(:success? => true) }
  let(:stop_output) { '' }

  before do
    allow(NginxStage).to receive_messages(
      active_users: [active_user], inactive_users: [], nginx_bin: '/usr/sbin/nginx'
    )
    allow(NginxStage).to receive(:pun_pid_path)
      .with(user: active_user).and_return('/tmp/passenger.pid')
    allow(NginxStage).to receive(:pun_socket_path)
      .with(user: active_user).and_return('/tmp/passenger.sock')
    allow(NginxStage::PidFile).to receive(:new)
      .with('/tmp/passenger.pid').and_return(pid_path)
    allow(NginxStage::SocketFile).to receive(:new)
      .with('/tmp/passenger.sock').and_return(socket)
    allow(generator).to receive(:session_count).with(active_user).and_return(0)
    allow(generator).to receive(:puts)
    allow(generator).to receive(:with_pun_lifecycle_lock)
      .with(user: active_user).and_yield
    allow(NginxStage).to receive(:clean_nginx_env).with(user: active_user)
    allow(NginxStage).to receive(:nginx_args)
      .with(user: active_user, signal: :stop).and_return(['stop'])
    allow(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'stop').and_return([stop_output, status])
  end

  it 'keeps active-user cleanup serialized through socket removal' do
    expect(generator).to receive(:with_pun_lifecycle_lock)
      .with(user: active_user).ordered.and_yield
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'stop').ordered.and_return(['', status])
    expect(generator).to receive(:wait_for_pun_socket_shutdown)
      .with(user: active_user).ordered

    generator.invoke
  end

  context 'when nginx stop fails' do
    let(:status) { double(:success? => false) }
    let(:stop_output) { 'stop failed' }

    it 'does not wait for cleanup that was not initiated' do
      expect(generator).to receive(:warn).with(stop_output)
      expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

      generator.invoke
    end
  end

  context 'when active-user PID state is invalid' do
    before do
      allow(NginxStage::PidFile).to receive(:new)
        .with('/tmp/passenger.pid').and_raise(NginxStage::InvalidPidFile, 'invalid PID file')
    end

    it 'preserves an existing socket instead of guessing process ownership' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/tmp/passenger.sock').and_return(true)
      expect(FileUtils).not_to receive(:rm_f)
      expect(generator).not_to receive(:run_nginx)

      expect { generator.invoke }.to output(/socket path still exists/).to_stderr
    end

    it 'removes only the invalid PID if there is no socket' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/tmp/passenger.sock').and_return(false)
      allow(File).to receive(:symlink?).and_call_original
      allow(File).to receive(:symlink?).with('/tmp/passenger.sock').and_return(false)
      expect(FileUtils).to receive(:rm_f).with('/tmp/passenger.pid')
      expect(generator).not_to receive(:run_nginx)

      expect { generator.invoke }.to output(/Removed invalid PID file/).to_stderr
    end
  end

  context 'when --skip-nginx is used for an active user' do
    let(:generator) { described_class.new(skip_nginx: true) }

    it 'never removes even an inactive PID or socket' do
      allow(pid_path).to receive(:running_process?).and_return(false)
      expect(generator).not_to receive(:cleanup_stale_files)
      expect(generator).not_to receive(:run_nginx)

      generator.invoke
    end
  end

  context 'with a disabled user' do
    let(:disabled_user) { 'deleted_user' }
    let(:disabled_pid_path) do
      instance_double(NginxStage::PidFile, pid: 1234, to_s: '/tmp/deleted_user/passenger.pid')
    end

    before do
      allow(NginxStage).to receive_messages(active_users: [], inactive_users: [disabled_user])
      allow(NginxStage).to receive(:pun_pid_path)
        .with(user: disabled_user).and_return('/tmp/deleted_user/passenger.pid')
      allow(NginxStage::PidFile).to receive(:new)
        .with('/tmp/deleted_user/passenger.pid').and_return(disabled_pid_path)
      allow(generator).to receive(:with_pun_lifecycle_lock)
        .with(user: disabled_user).and_yield
      allow(Process).to receive(:kill).with('TERM', 1234).and_return(1)
      allow(NginxStage).to receive(:pun_secret_key_base_path)
        .with(user: disabled_user).and_return('/tmp/deleted_user.secret')
      allow(NginxStage).to receive(:pun_config_path)
        .with(user: disabled_user).and_return('/tmp/deleted_user.conf')
      allow(FileUtils).to receive(:rm)
      allow(FileUtils).to receive(:rmdir)
    end

    it 'holds the lifecycle lock through SIGTERM socket cleanup' do
      expect(generator).to receive(:with_pun_lifecycle_lock)
        .with(user: disabled_user).ordered.and_yield
      expect(Process).to receive(:kill)
        .with('TERM', 1234).ordered.and_return(1)
      expect(generator).to receive(:wait_for_pun_socket_shutdown)
        .with(user: disabled_user).ordered

      generator.invoke
    end

    context 'with --skip-nginx' do
      let(:generator) { described_class.new(skip_nginx: true) }

      it 'displays the disabled user without signalling or deleting PUN state' do
        expect(generator).to receive(:puts).with('deleted_user (disabled)')
        expect(NginxStage::PidFile).not_to receive(:new)
        expect(Process).not_to receive(:kill)
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)
        expect(FileUtils).not_to receive(:rm)
        expect(FileUtils).not_to receive(:rmdir)

        generator.invoke
      end
    end

    context 'with a different --user' do
      let(:generator) { described_class.new(user: 'another_user') }

      it 'does not inspect, signal, lock or delete an unselected disabled user' do
        expect(generator).not_to receive(:with_pun_lifecycle_lock)
        expect(generator).not_to receive(:puts)
        expect(NginxStage::PidFile).not_to receive(:new)
        expect(Process).not_to receive(:kill)
        expect(FileUtils).not_to receive(:rm)
        expect(FileUtils).not_to receive(:rmdir)

        generator.invoke
      end
    end

    context 'with the matching --user' do
      let(:generator) { described_class.new(user: disabled_user) }

      it 'still reaches the selected user after skipping another disabled user' do
        allow(NginxStage).to receive(:inactive_users)
          .and_return(['another_disabled_user', disabled_user])
        expect(generator).not_to receive(:with_pun_lifecycle_lock)
          .with(user: 'another_disabled_user')
        expect(Process).to receive(:kill).with('TERM', 1234)
        expect(generator).to receive(:wait_for_pun_socket_shutdown)
          .with(user: disabled_user)
        expect(FileUtils).to receive(:rm).with('/tmp/deleted_user.secret')
        expect(FileUtils).to receive(:rm).with('/tmp/deleted_user.conf')

        generator.invoke
      end
    end

    it 'rejects an empty real PID file before signalling or deleting state' do
      Dir.mktmpdir('disabled-user-pid-spec') do |dir|
        path = File.join(dir, 'passenger.pid')
        File.write(path, '')
        allow(NginxStage).to receive(:pun_pid_path).with(user: disabled_user).and_return(path)
        allow(NginxStage::PidFile).to receive(:new).with(path).and_call_original
        expect(Process).not_to receive(:kill)
        expect(FileUtils).not_to receive(:rm)
        expect(FileUtils).not_to receive(:rmdir)
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

        expect { generator.invoke }
          .to output(/Error trying to clean up disabled user deleted_user: invalid PID file/).to_stderr
      end
    end

    context 'when SIGTERM is denied' do
      it 'preserves configuration and secrets for a potentially running PUN' do
        allow(Process).to receive(:kill).with('TERM', 1234).and_raise(Errno::EPERM)
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)
        expect(FileUtils).not_to receive(:rm)

        expect { generator.invoke }
          .to output(/Cannot terminate disabled user deleted_user/).to_stderr
      end
    end

    context 'when the recorded PID is gone' do
      before do
        allow(Process).to receive(:kill).with('TERM', 1234).and_raise(Errno::ESRCH)
      end

      it 'preserves configuration when the socket remains' do
        allow(NginxStage).to receive(:pun_socket_path)
          .with(user: disabled_user).and_return('/tmp/deleted_user/passenger.sock')
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?)
          .with('/tmp/deleted_user/passenger.sock').and_return(true)
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)
        expect(FileUtils).not_to receive(:rm)

        expect { generator.invoke }
          .to output(/PID is gone but socket path still exists/).to_stderr
      end

      it 'cleans configuration when the socket is also gone' do
        allow(NginxStage).to receive(:pun_socket_path)
          .with(user: disabled_user).and_return('/tmp/deleted_user/passenger.sock')
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?)
          .with('/tmp/deleted_user/passenger.sock').and_return(false)
        allow(File).to receive(:symlink?).and_call_original
        allow(File).to receive(:symlink?)
          .with('/tmp/deleted_user/passenger.sock').and_return(false)
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)
        expect(FileUtils).to receive(:rm).with('/tmp/deleted_user.secret')
        expect(FileUtils).to receive(:rm).with('/tmp/deleted_user.conf')

        generator.invoke
      end
    end
  end
end
