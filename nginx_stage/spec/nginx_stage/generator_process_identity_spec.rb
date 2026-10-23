# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::Generator do
  let(:directory) { Dir.mktmpdir('pun-identity-integration') }
  let(:user) { 'spec' }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'spec.conf') }
  let(:generator) { described_class.new }

  before do
    File.write(pid_path, '12345')
    File.write(config_path, 'original configuration')
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    allow(NginxStage).to receive_messages(
      pun_pid_path: pid_path, pun_socket_path: socket_path, pun_config_path: config_path,
      active_users: [user], inactive_users: [], pending_cleanup_users: []
    )
    allow(NginxStage::PunProcess).to receive(:state).and_return(:foreign)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'permits startup over an unrelated PID when the socket is absent without signaling' do
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(NginxStage).to receive(:nginx_bin).and_return('/usr/sbin/nginx')
    allow(NginxStage).to receive(:nginx_args).with(user: user).and_return(['start'])
    status = instance_double(Process::Status, success?: true)
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(Process).not_to receive(:kill)
    allow(Open3).to receive(:capture2e).with(['/usr/sbin/nginx', '(spec)'], 'start').and_return(['', status])

    expect(generator.send(:run_nginx, user: user)).to eq(['', status])
  end

  [false, true].each do |force|
    it "recovers an unrelated PID without signaling, force=#{force}" do
      cleaner = NginxStage::NginxCleanGenerator.new(force: force)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)

      expect { cleaner.invoke }.to output(/stale pid file removed/).to_stderr

      expect(File.exist?(pid_path)).to be(false)
      expect(File.read(config_path)).to eq('original configuration')
    end
  end

  [:matching, :unknown].each do |identity|
    it "preserves a #{identity} process and PID when its socket is absent" do
      allow(NginxStage::PunProcess).to receive(:state).and_return(identity)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)

      expect { generator.send(:run_nginx, user: user) }.to raise_error(NginxStage::Error)
      expect { NginxStage::NginxCleanGenerator.new(force: true).invoke }
        .to output(identity == :matching ? /possibly draining/ : /identity is uncertain/).to_stderr

      expect(File.read(pid_path)).to eq('12345')
      expect(File.read(config_path)).to eq('original configuration')
    end
  end

  it 'preserves unrelated PID state beside an uncertain socket path' do
    File.write(socket_path, 'occupied')
    expect(NginxStage::PunProcess).not_to receive(:signal)

    expect { generator.send(:run_nginx, user: user) }.to raise_error(NginxStage::Error, /socket path is occupied/)
    expect { NginxStage::NginxCleanGenerator.new(force: true).invoke }.to output(/socket path still exists/).to_stderr

    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(socket_path)).to eq('occupied')
  end

  it 'refuses a changed or unrelated signal target without running nginx -s' do
    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: user, signal: :stop)
      .and_raise(NginxStage::Error, 'Refusing unrelated process')
    expect(Process).not_to receive(:kill)
    expect(Open3).not_to receive(:capture2e)
    expect(generator).not_to receive(:wait_for_pun_shutdown)

    expect { generator.send(:run_nginx, user: user, signal: :stop) }
      .to raise_error(NginxStage::Error, 'Refusing unrelated process')
  end

  it 'recovers a disabled account with an unrelated PID without signaling it' do
    allow(NginxStage).to receive_messages(active_users: [], inactive_users: [user])
    allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
    allow(NginxStage).to receive(:pun_secret_key_base_path).and_return(File.join(directory, 'secret'))
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(Process).not_to receive(:kill)

    expect { NginxStage::NginxCleanGenerator.new.invoke }.to output("spec (disabled)\n").to_stdout
    expect(File.exist?(pid_path)).to be(false)
    expect(File.exist?(config_path)).to be(false)
  end
end
