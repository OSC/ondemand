# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::AppConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }
  let(:generator) do
    described_class.new(
      user:        test_user,
      sub_request: '/sys/dashboard'
    )
  end
  let(:hook) { generator.class.hooks[:exec_nginx] }
  let(:status) { instance_double(Process::Status, success?: true) }
  let(:pid_path) { '/var/run/ondemand-nginx/spec/passenger.pid' }
  let(:socket_path) { '/var/run/ondemand-nginx/spec/passenger.sock' }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell)
                   .new(test_user_gid, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(test_user_gid, test_user)

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(group)
    # RSpec may lazily load matchers after File.file? is stubbed below.
    allow(File).to receive(:file?).and_call_original
    allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
    allow(NginxStage).to receive(:pun_pid_path).with(user: generator.user).and_return(pid_path)
    allow(NginxStage::PidFile).to receive(:new)
      .with(pid_path).and_return(instance_double(NginxStage::PidFile))
    allow(NginxStage).to receive(:pun_socket_path).with(user: generator.user).and_return(socket_path)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user, signal: :stop).and_return(['stop'])
    allow(NginxStage).to receive(:nginx_args)
      .with(user: generator.user).and_return(['start'])
  end

  it 'serializes the complete app config operation for the user' do
    expect(generator).to receive(:with_pun_lifecycle_lock)
      .with(user: generator.user).and_yield
    allow(described_class).to receive(:hooks).and_return(
      probe: proc { @probe_ran = true }
    )

    generator.invoke

    expect(generator.instance_variable_get(:@probe_ran)).to be(true)
  end

  it 'waits for the old socket to disappear before starting the replacement PUN' do
    allow(File).to receive(:file?).with(pid_path).and_return(true)

    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: anything, user: generator.user, signal: :stop).ordered
    expect(generator).to receive(:wait_for_pun_shutdown)
      .with(user: generator.user).ordered
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start').ordered.and_return(['', status])

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  it 'does not wait when there was no PUN process to stop' do
    allow(File).to receive(:file?).with(pid_path).and_return(false)

    expect(generator).not_to receive(:wait_for_pun_shutdown)
    allow(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start').and_return(['', status])
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start')

    expect { generator.instance_eval(&hook) }
      .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  it 'does not wait or start a replacement when the stop command fails' do
    allow(File).to receive(:file?).with(pid_path).and_return(true)
    expect(NginxStage::PunProcess).to receive(:signal).and_raise(NginxStage::Error, 'stop failed')
    expect(Open3).not_to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start')
    expect(generator).not_to receive(:wait_for_pun_shutdown)

    expect { generator.instance_eval(&hook) }
      .to raise_error(NginxStage::Error, 'stop failed')
  end

  it 'does not start a replacement if socket cleanup times out' do
    allow(File).to receive(:file?).with(pid_path).and_return(true)
    expect(NginxStage::PunProcess).to receive(:signal)
    expect(generator).to receive(:wait_for_pun_shutdown)
      .with(user: generator.user).and_raise(NginxStage::Error, 'socket shutdown timed out')
    expect(Open3).not_to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start')

    expect { generator.instance_eval(&hook) }
      .to raise_error(NginxStage::Error, 'socket shutdown timed out')
  end

  it 'preserves configuration-only behavior with --skip-nginx' do
    generator = described_class.new(user: test_user, sub_request: '/sys/dashboard', skip_nginx: true)
    expect(Open3).not_to receive(:capture2e)
    expect(generator).not_to receive(:wait_for_pun_shutdown)

    generator.instance_eval(&hook)
  end
end
