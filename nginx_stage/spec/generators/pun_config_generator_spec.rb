# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::PunConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }

  before do
    etc_stub = {
      :gid   => test_user_gid,
      :name  => test_user,
      :uid   => 1000,
      :shell => '/bin/bash'
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


  describe 'concurrent startup protection' do
    let(:generator) { described_class.new(user: test_user) }
    let(:lock_path) { '/var/lib/ondemand-nginx/config/puns/spec.conf.lock' }
    let(:lock) { instance_double(File) }

    it 'takes an exclusive per-user lock while invoking startup hooks' do
      allow(NginxStage).to receive(:pun_config_path).with(user: generator.user)
        .and_return('/var/lib/ondemand-nginx/config/puns/spec.conf')
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:open)
        .with(lock_path, File::RDWR | File::CREAT, 0644)
        .and_yield(lock)
      expect(lock).to receive(:flock).with(File::LOCK_EX)
      allow(generator).to receive(:pun_running?).and_return(true)

      expect { generator.invoke }.to raise_error(NginxStage::LockFileError, 'Startup blocked because a PUN is already running')
    end

    it 'checks for an already-running PUN after normal user validation' do
      hook_names = described_class.hooks.keys
      running_check = hook_names.index(:skip_running_pun)

      expect(hook_names.index(:validate_user_not_special)).to be < running_check
      expect(hook_names.index(:block_user_with_disabled_shell)).to be < running_check
    end

    it 'stops setup when another request has already started the PUN' do
      original_hooks = described_class.hooks.dup
      skip_running_pun = original_hooks.fetch(:skip_running_pun)

      allow(described_class).to receive(:hooks).and_return(
        validation_probe: proc { @validation_probe_ran = true },
        skip_running_pun: skip_running_pun,
        setup_probe: proc { @setup_probe_ran = true }
      )
      allow(generator).to receive(:with_pun_start_lock).and_yield
      allow(generator).to receive(:pun_running?).and_return(true)

      expect { generator.invoke }.to raise_error(NginxStage::LockFileError, 'Startup blocked because a PUN is already running')

      expect(generator.instance_variable_get(:@validation_probe_ran)).to be(true)
      expect(generator.instance_variable_get(:@setup_probe_ran)).to be_nil
    end

    it 'does not suppress --skip-nginx configuration generation' do
      generator = described_class.new(user: test_user, skip_nginx: true)
      original_hooks = described_class.hooks.dup
      skip_running_pun = original_hooks.fetch(:skip_running_pun)

      allow(described_class).to receive(:hooks).and_return(
        skip_running_pun: skip_running_pun,
        setup_probe: proc { @setup_probe_ran = true }
      )
      allow(generator).to receive(:with_pun_start_lock).and_yield
      expect(generator).not_to receive(:pun_running?)

      generator.invoke

      expect(generator.instance_variable_get(:@setup_probe_ran)).to be(true)
    end
  end

  describe '#pun_running?' do
    let(:generator) { described_class.new(user: test_user) }
    let(:pid_file) { instance_double(NginxStage::PidFile) }

    before do
      allow(NginxStage).to receive(:pun_socket_path).with(user: generator.user)
        .and_return('/var/run/ondemand-nginx/spec/passenger.sock')
      allow(NginxStage).to receive(:pun_pid_path).with(user: generator.user)
        .and_return('/var/run/ondemand-nginx/spec/passenger.pid')
    end

    it 'requires both a socket and a live PID' do
      allow(File).to receive(:socket?)
        .with('/var/run/ondemand-nginx/spec/passenger.sock').and_return(true)
      allow(NginxStage::PidFile).to receive(:new)
        .with('/var/run/ondemand-nginx/spec/passenger.pid').and_return(pid_file)
      allow(pid_file).to receive(:running_process?).and_return(true)

      expect(generator.send(:pun_running?)).to be(true)
    end

    it 'treats missing PID state as not running' do
      allow(File).to receive(:socket?)
        .with('/var/run/ondemand-nginx/spec/passenger.sock').and_return(true)
      allow(NginxStage::PidFile).to receive(:new)
        .and_raise(NginxStage::MissingPidFile)

      expect(generator.send(:pun_running?)).to be(false)
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
