# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::NginxCleanGenerator do
  let(:generator) { described_class.new }
  let(:active_user) { double('user', to_s: 'spec') }
  let(:pid_path) { double('pid_path', running_process?: true) }
  let(:socket) { double('socket') }
  let(:status) { double(:success? => true) }

  before do
    allow(NginxStage).to receive(:active_users).and_return([active_user])
    allow(NginxStage).to receive(:inactive_users).and_return([])
    allow(NginxStage).to receive(:pun_pid_path).with(user: active_user).and_return('/tmp/passenger.pid')
    allow(NginxStage).to receive(:pun_socket_path).with(user: active_user).and_return('/tmp/passenger.sock')
    allow(NginxStage::PidFile).to receive(:new).with('/tmp/passenger.pid').and_return(pid_path)
    allow(NginxStage::SocketFile).to receive(:new).with('/tmp/passenger.sock').and_return(socket)
    allow(generator).to receive(:session_count).with(active_user).and_return(0)
    allow(generator).to receive(:puts)
    allow(generator).to receive(:with_pun_lifecycle_lock).with(user: active_user).and_yield
    allow(NginxStage).to receive(:clean_nginx_env).with(user: nil)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args)
      .with(user: active_user, signal: :stop)
      .and_return(['stop'])
    allow(Open3).to receive(:capture2e)
      .with('/usr/sbin/nginx', 'stop')
      .and_return(['', status])
  end

  it 'holds the lifecycle lock until the stopped PUN socket disappears' do
    expect(generator).to receive(:with_pun_lifecycle_lock).with(user: active_user).ordered.and_yield
    expect(Open3).to receive(:capture2e)
      .with('/usr/sbin/nginx', 'stop').ordered.and_return(['', status])
    expect(generator).to receive(:wait_for_pun_socket_shutdown)
      .with(user: active_user).ordered

    generator.invoke
  end

  context 'when nginx fails to stop' do
    let(:status) { double(:success? => false) }

    before do
      allow($stderr).to receive(:puts)
    end

    it 'does not wait for socket cleanup that was not initiated' do
      expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

      generator.invoke
    end
  end

  context 'with a disabled user' do
    let(:disabled_user) { 'deleted_user' }
    let(:disabled_pid_path_value) { '/tmp/deleted_user/passenger.pid' }
    let(:disabled_pid_path) do
      double('disabled_pid_path', pid: 1234, to_s: disabled_pid_path_value)
    end
    let(:kill_status) { double(:success? => true) }

    before do
      allow(NginxStage).to receive(:active_users).and_return([])
      allow(NginxStage).to receive(:inactive_users).and_return([disabled_user])
      allow(NginxStage).to receive(:pun_pid_path)
        .with(user: disabled_user)
        .and_return(disabled_pid_path_value)
      allow(NginxStage::PidFile).to receive(:new)
        .with(disabled_pid_path_value)
        .and_return(disabled_pid_path)
      allow(generator).to receive(:with_pun_lifecycle_lock).with(user: disabled_user).and_yield
      allow(Open3).to receive(:capture2e)
        .with('kill', '-s', 'TERM', '1234')
        .and_return(['', kill_status])
      allow(NginxStage).to receive(:pun_secret_key_base_path)
        .with(user: disabled_user)
        .and_return('/tmp/deleted_user.secret_key_base.txt')
      allow(NginxStage).to receive(:pun_config_path)
        .with(user: disabled_user)
        .and_return('/tmp/deleted_user.conf')
      allow(FileUtils).to receive(:rm)
      allow(FileUtils).to receive(:rmdir)
    end

    it 'holds the lifecycle lock until the disabled PUN socket disappears' do
      expect(generator).to receive(:with_pun_lifecycle_lock).with(user: disabled_user).ordered.and_yield
      expect(Open3).to receive(:capture2e)
        .with('kill', '-s', 'TERM', '1234').ordered.and_return(['', kill_status])
      expect(generator).to receive(:wait_for_pun_socket_shutdown)
        .with(user: disabled_user).ordered

      generator.invoke
    end

    context 'when SIGTERM fails' do
      let(:kill_status) { double(:success? => false) }

      it 'does not wait for socket cleanup that was not initiated' do
        expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

        generator.invoke
      end
    end
  end
end
