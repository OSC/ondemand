# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::Generator do
  let(:test_user) { 'spec' }
  let(:directory) { Dir.mktmpdir('pun-shutdown-spec') }
  let(:config_path) { File.join(directory, 'spec.conf') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:status) { instance_double(Process::Status, success?: true) }
  let(:generator) { described_class.new }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell)
                   .new(1000, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, test_user)
    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
    allow(NginxStage).to receive_messages(
      pun_config_path: config_path, pun_pid_path: pid_path,
      pun_socket_path: socket_path, nginx_bin: '/usr/sbin/nginx'
    )
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(NginxStage).to receive(:nginx_args) do |signal: nil, **|
      [signal ? signal.to_s : 'start']
    end
    File.write(config_path, 'original configuration')
  end

  after do
    FileUtils.remove_entry(directory)
  end

  { stop: [:pid, :socket], quit: [:socket, :pid] }.each do |signal, order|
    it "waits for both paths when #{signal} removes the #{order.first} path first" do
      paths = { pid: pid_path, socket: socket_path }
      File.write(pid_path, Process.pid.to_s)
      # Ordinary files exercise pathname lifetime without requiring live nginx.
      File.write(socket_path, 'occupied')
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], signal.to_s) do
          File.unlink(paths.fetch(order.first))
          ['', status]
        end
      expect(generator).to receive(:sleep).once do
        expect(File.exist?(paths.fetch(order.last))).to be(true)
        File.unlink(paths.fetch(order.last))
      end

      expect(generator.send(:run_nginx, user: test_user, signal: signal)).to eq(['', status])
      expect(File.exist?(pid_path)).to be(false)
      expect(File.exist?(socket_path)).to be(false)
    end
  end

  it 'does not regard a dangling PID symlink as completed shutdown' do
    File.write(pid_path, Process.pid.to_s)
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'quit') do
        File.unlink(pid_path)
        File.symlink(File.join(directory, 'missing-target'), pid_path)
        ['', status]
      end
    stub_const('NginxStage::Generator::PUN_SHUTDOWN_TIMEOUT', 0)

    expect { generator.send(:run_nginx, user: test_user, signal: :quit) }
      .to raise_error(NginxStage::Error, /timed out waiting for PUN.*shutdown/)
    expect(File.symlink?(pid_path)).to be(true)
  end

  [:pun, :direct].each do |entry_point|
    it "blocks #{entry_point} startup after quit times out, then permits a manageable replacement" do
      File.write(pid_path, Process.pid.to_s)
      File.write(socket_path, 'occupied')
      stub_const('NginxStage::Generator::PUN_SHUTDOWN_TIMEOUT', 0)
      shutdown = NginxStage::NginxProcessGenerator.new(user: test_user, signal: :quit)
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'quit') do
          File.unlink(socket_path)
          ['', status]
        end

      expect { shutdown.invoke }
        .to raise_error(NginxStage::Error, /timed out waiting for PUN.*shutdown/)
      expect(File.read(pid_path)).to eq(Process.pid.to_s)
      expect(File.exist?(socket_path)).to be(false)
      expect(File.read(config_path)).to eq('original configuration')
      File.open("#{config_path}.lock", File::RDWR) do |competitor|
        expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
      end

      startup = if entry_point == :pun
                  hooks = NginxStage::PunConfigGenerator.hooks
                  allow(NginxStage::PunConfigGenerator).to receive(:hooks).and_return(
                    skip_running_pun: hooks.fetch(:skip_running_pun),
                    setup_probe:      proc { File.write(config_path, 'replacement configuration') },
                    exec_nginx:       hooks.fetch(:exec_nginx)
                  )
                  NginxStage::PunConfigGenerator.new(user: test_user)
                else
                  NginxStage::NginxProcessGenerator.new(user: test_user)
                end
      allow(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start')
        .and_raise('replacement started before the old PID path was removed')

      expect { startup.invoke }
        .to raise_error(NginxStage::Error, 'Startup blocked because a PUN is already running')
      expect(File.read(pid_path)).to eq(Process.pid.to_s)
      expect(File.read(config_path)).to eq('original configuration')

      File.open("#{config_path}.lock", File::RDWR) do |competitor|
        expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
      end

      # Model the old master finishing its drain before retrying startup.
      File.unlink(pid_path)
      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'start') do
          expect(File.exist?(pid_path)).to be(false)
          expect(File.exist?(socket_path)).to be(false)
          File.open("#{config_path}.lock", File::RDWR) do |competitor|
            expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
          end
          File.write(pid_path, '12345')
          File.write(socket_path, 'replacement socket')
          ['', status]
        end

      expect { startup.invoke }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
      expect(File.read(pid_path)).to eq('12345')

      expect(Open3).to receive(:capture2e)
        .with(['/usr/sbin/nginx', '(spec)'], 'stop') do
          expect(File.read(pid_path)).to eq('12345')
          File.unlink(pid_path)
          File.unlink(socket_path)
          ['', status]
        end
      stop = NginxStage::NginxProcessGenerator.new(user: test_user, signal: :stop)
      expect { stop.invoke }
        .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end
  end

  ['not-a-pid', ''].each do |contents|
    it "rejects a PID-only startup with unusable PID contents #{contents.inspect}" do
      File.write(pid_path, contents)
      expect(Open3).not_to receive(:capture2e)
      expect(NginxStage).not_to receive(:clean_nginx_env)

      expect { generator.send(:run_nginx, user: test_user) }
        .to raise_error(NginxStage::Error, /PID state is unusable/)
      expect(File.read(pid_path)).to eq(contents)
    end
  end

  it 'permits startup with an absent socket and a confirmed dead PID' do
    File.write(pid_path, '12345')
    allow(Process).to receive(:getpgid).with(12_345).and_raise(Errno::ESRCH)
    expect(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start').once.and_return(['', status])

    expect(generator.send(:run_nginx, user: test_user)).to eq(['', status])
  end

  it 'blocks app replacement when its shared PID path is a dangling symlink' do
    File.symlink(File.join(directory, 'missing-target'), pid_path)
    app = NginxStage::AppConfigGenerator.new(user: test_user, sub_request: '/sys/dashboard')
    expect(Open3).not_to receive(:capture2e)

    expect { app.instance_eval(&NginxStage::AppConfigGenerator.hooks.fetch(:exec_nginx)) }
      .to raise_error(NginxStage::Error, /PID state is unusable/)
  end
end
