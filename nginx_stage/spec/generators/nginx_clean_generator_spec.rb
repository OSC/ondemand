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
    allow(generator).to receive(:with_pun_restart_lock).with(user: active_user).and_yield
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
    expect(generator).to receive(:with_pun_restart_lock).with(user: active_user).ordered.and_yield
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
end
