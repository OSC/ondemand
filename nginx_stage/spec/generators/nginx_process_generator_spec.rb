# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::NginxProcessGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }
  let(:signal) { :stop }
  let(:generator) { described_class.new(user: test_user, signal: signal) }
  let(:hook) { generator.class.hooks[:exec_nginx] }
  let(:status) { double(:success? => true) }

  before do
    etc_stub = {
      :gid  => test_user_gid,
      :name => test_user
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(generator).to receive(:with_pun_restart_lock).with(user: generator.user).and_yield
    allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user, signal: signal)
      .and_return(['nginx-args'])
    allow(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'nginx-args')
      .and_return(['', status])
  end

  it 'keeps the lifecycle lock until a stop removes the PUN socket' do
    expect(generator).to receive(:with_pun_restart_lock).with(user: generator.user).ordered.and_yield
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'nginx-args').ordered.and_return(['', status])
    expect(generator).to receive(:wait_for_pun_socket_shutdown)
      .with(user: generator.user).ordered

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  context 'with a graceful quit' do
    let(:signal) { :quit }

    it 'also waits for the PUN socket to disappear' do
      expect(generator).to receive(:wait_for_pun_socket_shutdown).with(user: generator.user)

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end
  end

  context 'with a non-shutdown signal' do
    let(:signal) { :reload }

    it 'does not wait for the PUN socket to disappear' do
      expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end
  end
end
