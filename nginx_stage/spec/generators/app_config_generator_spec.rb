# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::AppConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }
  let(:generator) do
    described_class.new(
      user: test_user,
      sub_request: '/sys/dashboard'
    )
  end
  let(:hook) { generator.class.hooks[:exec_nginx] }
  let(:status) { double(:success? => true) }
  let(:pid_path) { '/var/run/ondemand-nginx/spec/passenger.pid' }
  let(:socket_path) { '/var/run/ondemand-nginx/spec/passenger.sock' }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell)
      .new(test_user_gid, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(test_user_gid, test_user)

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(group)
    allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
    allow(NginxStage).to receive(:pun_pid_path).with(user: generator.user).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).with(user: generator.user).and_return(socket_path)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user, signal: :stop).and_return(['stop'])
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user).and_return(['start'])
  end

  it 'serializes the complete app config operation for the user' do
    expect(generator).to receive(:with_pun_app_lock).and_yield
    allow(described_class).to receive(:hooks).and_return(
      probe: proc { @probe_ran = true }
    )

    generator.invoke

    expect(generator.instance_variable_get(:@probe_ran)).to be(true)
  end

  it 'waits for the old socket to disappear before starting the replacement PUN' do
    allow(File).to receive(:file?).with(pid_path).and_return(true)

    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'stop').ordered.and_return(['', status])
    expect(generator).to receive(:wait_for_pun_socket_shutdown).ordered
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start').ordered.and_return(['', status])

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  it 'does not wait when there was no PUN process to stop' do
    allow(File).to receive(:file?).with(pid_path).and_return(false)

    expect(generator).not_to receive(:wait_for_pun_socket_shutdown)
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start').and_return(['', status])

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  describe '#wait_for_pun_socket_shutdown' do
    it 'waits for an ordinary socket path to disappear' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(true, false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(false)

      expect(generator).to receive(:sleep)
        .with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once

      generator.send(:wait_for_pun_socket_shutdown)
    end

    it 'also waits for a dangling symlink at the socket path' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(true, false)

      expect(generator).to receive(:sleep)
        .with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once

      generator.send(:wait_for_pun_socket_shutdown)
    end

    it 'fails instead of starting over a socket that never disappears' do
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
end
