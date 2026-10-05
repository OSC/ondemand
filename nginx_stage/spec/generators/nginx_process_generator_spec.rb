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
    passwd = Struct.new(:gid, :name, :uid, :shell)
      .new(test_user_gid, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(test_user_gid, test_user)

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(group)
    allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user, signal: signal).and_return(['nginx-args'])
    allow(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'nginx-args')
      .and_return(['', status])
  end

  it 'holds the lifecycle lock until stop removes the socket' do
    expect(generator).to receive(:with_pun_lifecycle_lock)
      .with(user: generator.user).and_yield
    expect(generator).to receive(:wait_for_pun_socket_shutdown)
      .with(user: generator.user)

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  context 'with graceful quit' do
    let(:signal) { :quit }

    it 'also waits for socket cleanup while holding the lifecycle lock' do
      expect(generator).to receive(:with_pun_lifecycle_lock)
        .with(user: generator.user).and_yield
      expect(generator).to receive(:wait_for_pun_socket_shutdown)
        .with(user: generator.user)

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end
  end

  context 'with reload' do
    let(:signal) { :reload }

    it 'does not take the shutdown lifecycle lock' do
      expect(generator).not_to receive(:with_pun_lifecycle_lock)
      expect(generator).not_to receive(:wait_for_pun_socket_shutdown)

      expect { generator.instance_eval(&hook) }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end
  end
end
