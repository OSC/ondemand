# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::PunConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }
  let(:generator) { described_class.new(user: test_user, skip_nginx: true) }

  before do
    etc_stub = {
      :gid  => test_user_gid,
      :name => test_user
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
  end

  it 'has the correct options' do
    expect(described_class.options.keys).to eq([:user, :skip_nginx, :app_init_url, :pre_hook_root_cmd])
  end

  it 'requires the user option' do
    expect { described_class.new }.to raise_error(NginxStage::MissingOption, 'missing option: user')
  end

  describe '#invoke' do
    before do
      allow(described_class).to receive(:hooks).and_return(
        probe: proc { @pun_lock_probe_ran = true }
      )
    end

    it 'holds the PUN lifecycle lock across all setup hooks' do
      expect(generator).to receive(:with_pun_restart_lock).with(user: generator.user).and_yield(false)

      generator.invoke

      expect(generator.instance_variable_get(:@pun_lock_probe_ran)).to be(true)
    end

    it 'does not suppress an uncontended explicit initialization of an existing PUN' do
      running_generator = described_class.new(user: test_user)
      expect(running_generator).to receive(:pun_running?)
        .with(user: running_generator.user)
        .once
        .and_return(true)
      expect(running_generator).to receive(:with_pun_restart_lock)
        .with(user: running_generator.user)
        .and_yield(false)

      running_generator.invoke

      expect(running_generator.instance_variable_get(:@pun_lock_probe_ran)).to be(true)
    end

    it 'skips duplicate initialization after waiting when another operation started the PUN' do
      running_generator = described_class.new(user: test_user)
      expect(running_generator).to receive(:pun_running?)
        .with(user: running_generator.user)
        .twice
        .and_return(false, true)
      expect(running_generator).to receive(:with_pun_restart_lock)
        .with(user: running_generator.user)
        .and_yield(true)

      running_generator.invoke

      expect(running_generator.instance_variable_get(:@pun_lock_probe_ran)).to be_nil
    end

    it 'retries initialization after waiting when the PUN is still not running' do
      running_generator = described_class.new(user: test_user)
      expect(running_generator).to receive(:pun_running?)
        .with(user: running_generator.user)
        .twice
        .and_return(false, false)
      expect(running_generator).to receive(:with_pun_restart_lock)
        .with(user: running_generator.user)
        .and_yield(true)

      running_generator.invoke

      expect(running_generator.instance_variable_get(:@pun_lock_probe_ran)).to be(true)
    end

    it 'does not suppress a contended explicit initialization when the PUN was already running' do
      running_generator = described_class.new(user: test_user)
      expect(running_generator).to receive(:pun_running?)
        .with(user: running_generator.user)
        .once
        .and_return(true)
      expect(running_generator).to receive(:with_pun_restart_lock)
        .with(user: running_generator.user)
        .and_yield(true)

      running_generator.invoke

      expect(running_generator.instance_variable_get(:@pun_lock_probe_ran)).to be(true)
    end

    it 'does not suppress config-only generation after waiting' do
      expect(generator).to receive(:with_pun_restart_lock).with(user: generator.user).and_yield(true)
      expect(generator).not_to receive(:pun_running?)

      generator.invoke

      expect(generator.instance_variable_get(:@pun_lock_probe_ran)).to be(true)
    end
  end

  describe '#pun_running?' do
    let(:running_generator) { described_class.new(user: test_user) }
    let(:pid_path) { '/var/run/ondemand-nginx/spec/passenger.pid' }
    let(:socket_path) { '/var/run/ondemand-nginx/spec/passenger.sock' }
    let(:pid_file) { double('pid_file') }

    before do
      allow(NginxStage).to receive(:pun_pid_path).with(user: running_generator.user).and_return(pid_path)
      allow(NginxStage).to receive(:pun_socket_path).with(user: running_generator.user).and_return(socket_path)
    end

    it 'requires both a live PID and a socket' do
      allow(File).to receive(:socket?).with(socket_path).and_return(true)
      allow(NginxStage::PidFile).to receive(:new).with(pid_path).and_return(pid_file)
      allow(pid_file).to receive(:running_process?).and_return(true)

      expect(running_generator.send(:pun_running?, user: running_generator.user)).to be(true)
    end

    it 'does not treat a live PID without a socket as a running PUN' do
      allow(File).to receive(:socket?).with(socket_path).and_return(false)
      expect(NginxStage::PidFile).not_to receive(:new)

      expect(running_generator.send(:pun_running?, user: running_generator.user)).to be(false)
    end

    it 'does not treat a stale PID as a running PUN' do
      allow(File).to receive(:socket?).with(socket_path).and_return(true)
      allow(NginxStage::PidFile).to receive(:new).with(pid_path).and_return(pid_file)
      allow(pid_file).to receive(:running_process?).and_return(false)

      expect(running_generator.send(:pun_running?, user: running_generator.user)).to be(false)
    end

    it 'does not treat a missing PID file as a running PUN' do
      allow(File).to receive(:socket?).with(socket_path).and_return(true)
      allow(NginxStage::PidFile).to receive(:new).with(pid_path).and_raise(NginxStage::MissingPidFile)

      expect(running_generator.send(:pun_running?, user: running_generator.user)).to be(false)
    end
  end

  describe 'missing user' do
    let(:missing_user) { 'nobody_here' }

    before do
      allow(Etc).to receive(:getpwnam).with(missing_user)
        .and_raise(ArgumentError, "can't find user for #{missing_user}")
    end

    it 'raises InvalidUser with the default missing_user_message' do
      expect { described_class.new({ :user => missing_user }) }
        .to raise_error(NginxStage::InvalidUser, "can't find user for nobody_here")
    end

    it 'raises InvalidUser with a custom missing_user_message' do
      allow(NginxStage).to receive(:missing_user_message)
        .and_return('User %s was not found. Ask your advisor to add you to an HPC allocation.')

      expect { described_class.new({ :user => missing_user }) }
        .to raise_error(
          NginxStage::InvalidUser,
          'User nobody_here was not found. Ask your advisor to add you to an HPC allocation.'
        )
    end
  end

  describe 'pre_hook_root_cmd' do
    let(:generator)  do
      described_class.new({
                            :user              => test_user,
                            :pre_hook_root_cmd => '/opt/pre_hook'
                          })
    end

    let(:hook) do
      generator.class.hooks[:exec_pre_hook]
    end

    it 'invokes the right root pre hook' do
      allow(Open3).to receive(:capture3).with('/opt/pre_hook', '--user', test_user)
      generator.instance_eval(&hook)
    end

    it 'logs exceptions from underlying script' do
      allow(Open3).to receive(:capture3).with('/opt/pre_hook', '--user',
                                              test_user).and_raise(StandardError.new('this is a test'))
      allow_any_instance_of(Syslog::Logger).to receive(:error).with("/opt/pre_hook threw exception 'this is a test' for spec")
      generator.instance_eval(&hook)
    end

    it 'logs non-zero exits from underlying script' do
      allow(Open3).to receive(:capture3)
        .with('/opt/pre_hook', '--user', test_user)
        .and_return(['', 'this is the test stderr message', double(:success? => false, :exitstatus => 3)])

      allow_any_instance_of(Syslog::Logger).to receive(:error)
        .with("/opt/pre_hook exited with 3 for user spec. stderr was 'this is the test stderr message'")

      generator.instance_eval(&hook)
    end
  end
end
