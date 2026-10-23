# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::AppConfigGenerator do
  let(:directory) { Dir.mktmpdir('app-stale-') }
  let(:user) { 'spec' }
  let(:pid_path) { File.join(directory, 'pun.pid') }
  let(:socket_path) { File.join(directory, 'pun.sock') }
  let(:generator) { described_class.new(user: user, sub_request: '/sys/dashboard') }
  let(:started) { instance_double(Process::Status, success?: true) }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(Struct.new(:name).new(user))
    allow(NginxStage).to receive_messages(pun_config_path: File.join(directory, 'pun.conf'),
                                          pun_pid_path: pid_path, pun_socket_path: socket_path)
    allow(NginxStage).to receive(:clean_nginx_env)
    # Retain the real invoke/lock and exec hook; app-root staging is independent.
    allow(described_class).to receive(:hooks).and_return(exec_nginx: described_class.hooks.fetch(:exec_nginx))
    File.write(pid_path, '12345')
  end

  after { FileUtils.remove_entry(directory) }

  [:dead, :foreign].each do |identity|
    it "replaces #{identity} PID state without signaling it when no socket remains" do
      allow(NginxStage::PunProcess).to receive(:state).and_return(identity)
      allow(Open3).to receive(:capture2e).and_return(['', started])
      expect(Open3).to receive(:capture2e).once
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect { generator.invoke }.to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
    end

    it "preserves an occupied socket beside #{identity} PID state" do
      File.write(socket_path, 'preserve')
      allow(NginxStage::PunProcess).to receive(:state).and_return(identity)
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(Open3).not_to receive(:capture2e)
      expect { generator.invoke }.to raise_error(NginxStage::Error, /socket path is occupied/)
      expect(File.read(pid_path)).to eq('12345')
      expect(File.read(socket_path)).to eq('preserve')
    end
  end

  it 'preserves unknown process identity without signaling or starting' do
    allow(NginxStage::PunProcess).to receive(:state).and_return(:unknown)
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(Open3).not_to receive(:capture2e)
    expect { generator.invoke }.to raise_error(NginxStage::Error, /identity is uncertain/)
    expect(File.read(pid_path)).to eq('12345')
  end

  it 'rechecks startup safety when the verified master exits before stop delivery' do
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching, :dead)
    allow(NginxStage::PunProcess).to receive(:signal).and_raise(Errno::ESRCH)
    allow(Open3).to receive(:capture2e).and_return(['', started])
    expect(Open3).to receive(:capture2e).once
    expect { generator.invoke }.to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
  end

  it 'preserves an occupied socket after the master exits before stop delivery' do
    File.write(socket_path, 'preserve')
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching, :dead)
    allow(NginxStage::PunProcess).to receive(:signal).and_raise(Errno::ESRCH)
    expect(Open3).not_to receive(:capture2e)
    expect { generator.invoke }.to raise_error(NginxStage::Error, /socket path is occupied/)
    expect(File.read(socket_path)).to eq('preserve')
    expect(File.read(pid_path)).to eq('12345')
  end

  [NginxStage::MissingPidFile, Errno::ENOENT].each do |pid_error|
    [false, true].each do |occupied_socket|
      it "rechecks #{pid_error} before stop, occupied socket=#{occupied_socket}" do
        File.write(socket_path, 'preserve') if occupied_socket
        allow(NginxStage::PunProcess).to receive(:state) do
          File.unlink(pid_path)
          :matching
        end
        if pid_error == Errno::ENOENT
          allow(NginxStage::PidFile).to receive(:new).and_wrap_original do |original, path|
            # Model disappearance during read, after the constructor's checks.
            raise Errno::ENOENT, path unless File.exist?(path)

            original.call(path)
          end
        end
        expect(NginxStage::PunProcess).not_to receive(:signal)
        if occupied_socket
          expect(Open3).not_to receive(:capture2e)
          expect { generator.invoke }.to raise_error(NginxStage::Error, /PID state is unusable/)
          expect(File.read(socket_path)).to eq('preserve')
        else
          allow(Open3).to receive(:capture2e).and_return(['', started])
          expect(Open3).to receive(:capture2e).once
          expect { generator.invoke }.to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
        end
      end
    end
  end
end
