# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::Generator do
  let(:user) { 'spec' }
  let(:directory) { Dir.mktmpdir('nginx-signal-validation') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'pun.conf') }
  let(:generator) { described_class.new }
  let(:status) { NginxStage::Generator::SignalStatus.new(0) }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, user)
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
    allow(NginxStage).to receive_messages(
      pun_pid_path: pid_path, pun_socket_path: socket_path,
      pun_config_path: config_path, nginx_bin: '/usr/sbin/nginx'
    )
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(NginxStage).to receive(:nginx_args) do |signal: nil, **|
      ['-s', signal.to_s]
    end
  end

  after do
    FileUtils.remove_entry(directory)
  end

  ['stop', 'quit', 'reload', 'reopen'].each do |signal|
    [20, 22].each do |padding|
      it "rejects #{padding} leading zeros before invoking nginx for #{signal}" do
        contents = "#{'0' * padding}12345"
        File.write(pid_path, contents)
        controller = NginxStage::NginxProcessGenerator.new(user: user, signal: signal)
        expect(Open3).not_to receive(:capture2e)
        expect(NginxStage).not_to receive(:clean_nginx_env)

        expect { controller.invoke }.to raise_error(NginxStage::InvalidPidFile)
        expect(File.read(pid_path)).to eq(contents)
      end
    end

    it "rejects PID zero before invoking nginx for #{signal}" do
      File.write(pid_path, '0')
      controller = NginxStage::NginxProcessGenerator.new(user: user, signal: signal)
      expect(Open3).not_to receive(:capture2e)
      expect(NginxStage).not_to receive(:clean_nginx_env)

      expect { controller.invoke }.to raise_error(NginxStage::InvalidPidFile)
      expect(File.read(pid_path)).to eq('0')
      if ['stop', 'quit'].include?(signal)
        File.open("#{config_path}.lock", File::RDWR) do |competitor|
          expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
        end
      end
    end

    it "uses guarded process signaling for #{signal} with a valid PID" do
      File.write(pid_path, Process.pid.to_s)
      expect(Open3).not_to receive(:capture2e)
      expect(NginxStage::PunProcess).to receive(:signal)
        .with(pid_file: have_attributes(pid: Process.pid), user: user, signal: signal) do
          File.unlink(pid_path) if ['stop', 'quit'].include?(signal)
          ['', status]
        end

      expect(generator.send(:run_nginx, user: user, signal: signal)).to eq(['', status])
    end
  end

  ['not-a-pid', '4294967296'].each do |contents|
    it "rejects unusable PID contents #{contents.inspect} before signalling" do
      File.write(pid_path, contents)
      expect(Open3).not_to receive(:capture2e)
      expect(NginxStage).not_to receive(:clean_nginx_env)

      expect { generator.send(:run_nginx, user: user, signal: :stop) }
        .to raise_error(NginxStage::InvalidPidFile)
    end
  end

  it 'rejects a missing PID before invoking nginx for a signal' do
    expect(Open3).not_to receive(:capture2e)
    expect(NginxStage).not_to receive(:clean_nginx_env)

    expect { generator.send(:run_nginx, user: user, signal: :stop) }
      .to raise_error(NginxStage::MissingPidFile)
  end

  it 'does not execute app stop or replacement startup with PID zero' do
    File.write(pid_path, '0')
    app = NginxStage::AppConfigGenerator.new(user: user, sub_request: '/sys/dashboard')
    allow(NginxStage::AppConfigGenerator).to receive(:hooks).and_return(
      exec_nginx: NginxStage::AppConfigGenerator.hooks.fetch(:exec_nginx)
    )
    expect(Open3).not_to receive(:capture2e)
    expect(NginxStage).not_to receive(:clean_nginx_env)

    expect { app.invoke }.to raise_error(NginxStage::Error, /PID state is unusable/)
    expect(File.read(pid_path)).to eq('0')
    File.open("#{config_path}.lock", File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
    end
  end

  it 'preserves command-only output for --skip-nginx without validating or signalling PID zero' do
    File.write(pid_path, '0')
    controller = NginxStage::NginxProcessGenerator.new(user: user, signal: 'stop', skip_nginx: true)
    expect(Open3).not_to receive(:capture2e)
    expect(NginxStage::PidFile).not_to receive(:new)

    expect { controller.invoke }.to output("Requested process signal: stop for spec; no signal sent\n").to_stdout
    expect(File.read(pid_path)).to eq('0')
  end

  it 'prints the startup command without inspecting PID state or running nginx for --skip-nginx' do
    File.write(pid_path, '0')
    controller = NginxStage::NginxProcessGenerator.new(user: user, skip_nginx: true)
    allow(NginxStage).to receive(:nginx_args).with(user: controller.user).and_return(['-c', config_path])
    expect(Open3).not_to receive(:capture2e)
    expect(NginxStage::PidFile).not_to receive(:new)
    expect(NginxStage::PunProcess).not_to receive(:signal)

    expect { controller.invoke }
      .to output("/usr/sbin/nginx -c #{config_path}\n").to_stdout.and output('').to_stderr
    expect(File.read(pid_path)).to eq('0')
    expect(File.exist?("#{config_path}.lock")).to be(false)
  end
end
