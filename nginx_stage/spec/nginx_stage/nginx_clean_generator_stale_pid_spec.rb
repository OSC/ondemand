# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::NginxCleanGenerator do
  let(:user) { 'deleted_user' }
  let(:generator) { described_class.new }
  let(:directory) { Dir.mktmpdir('nginx-clean-stale-pid') }
  let(:pid_root) { File.join(directory, 'run', user) }
  let(:pid_path) { File.join(pid_root, 'passenger.pid') }
  let(:socket_path) { File.join(pid_root, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'pun.conf') }
  let(:secret_path) { File.join(directory, 'pun.secret') }

  before do
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching)
    allow(NginxStage).to receive(:pending_cleanup_users).and_return([])
    FileUtils.mkdir_p(pid_root)
    File.write(pid_path, '1234')
    File.write(config_path, 'config')
    File.write(secret_path, 'secret')
    allow(NginxStage).to receive_messages(active_users: [], inactive_users: [user])
    allow(NginxStage).to receive(:pun_pid_path).with(user: user).and_return(pid_path)
    allow(NginxStage).to receive(:pun_pid_path)
      .with(user: '*').and_return(File.join(directory, 'run', '*', 'passenger.pid'))
    allow(NginxStage).to receive(:pun_socket_path).with(user: user).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).with(user: user).and_return(secret_path)
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 1234), user: anything, signal: :stop).and_raise(Errno::ESRCH)
    allow(generator).to receive(:puts)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  [[], [:secret], [:config], [:secret, :config]].each do |missing|
    it "completes dead-PID cleanup with these files already missing: #{missing.inspect}" do
      File.unlink(secret_path) if missing.include?(:secret)
      File.unlink(config_path) if missing.include?(:config)

      expect { generator.invoke }.not_to output.to_stderr

      expect(File.exist?(pid_root)).to be(false)
      expect(File.exist?(config_path)).to be(false)
      expect(File.exist?(secret_path)).to be(false)
    end
  end

  it 'holds the lifecycle lock while removing the stale PID' do
    allow(FileUtils).to receive(:rm).and_wrap_original do |original, path|
      if path == pid_path
        File.open("#{config_path}.lock", File::RDWR) do |competitor|
          expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
        end
      end
      original.call(path)
    end

    generator.invoke

    expect(File.exist?(pid_path)).to be(false)
  end

  it 'finishes cleanup if the PID file disappears after it is read' do
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 1234), user: anything, signal: :stop) do
      File.unlink(pid_path)
      raise Errno::ESRCH
    end

    expect { generator.invoke }.not_to output.to_stderr

    expect(File.exist?(pid_root)).to be(false)
    expect(File.exist?(config_path)).to be(false)
    expect(File.exist?(secret_path)).to be(false)
  end

  it 'preserves files when the socket path is still occupied' do
    File.write(socket_path, 'occupied')

    expect { generator.invoke }.to output(/socket path still exists/).to_stderr

    expect(File.read(pid_path)).to eq('1234')
    expect(File.read(config_path)).to eq('config')
    expect(File.read(secret_path)).to eq('secret')
    expect(File.read(socket_path)).to eq('occupied')
  end

  it 'preserves files when the socket path is a dangling symlink' do
    File.symlink(File.join(directory, 'missing-target'), socket_path)

    expect { generator.invoke }.to output(/socket path still exists/).to_stderr

    expect(File.read(pid_path)).to eq('1234')
    expect(File.read(config_path)).to eq('config')
    expect(File.read(secret_path)).to eq('secret')
    expect(File.symlink?(socket_path)).to be(true)
  end

  it 'reports a PID deletion error without deleting configuration or secrets' do
    allow(FileUtils).to receive(:rm).and_call_original
    allow(FileUtils).to receive(:rm).with(pid_path).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Permission denied/).to_stderr

    expect(File.read(pid_path)).to eq('1234')
    expect(File.read(config_path)).to eq('config')
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'preserves files when signaling is denied' do
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 1234), user: anything, signal: :stop).and_raise(Errno::EPERM)

    expect { generator.invoke }.to output(/Cannot terminate disabled user/).to_stderr

    expect(File.read(pid_path)).to eq('1234')
    expect(File.read(config_path)).to eq('config')
    expect(File.read(secret_path)).to eq('secret')
  end

  context 'with --skip-nginx' do
    let(:generator) { described_class.new(skip_nginx: true) }

    it 'preserves all files and avoids signaling' do
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect(Process).not_to receive(:kill)

      generator.invoke

      expect(File.read(pid_path)).to eq('1234')
      expect(File.read(config_path)).to eq('config')
      expect(File.read(secret_path)).to eq('secret')
      expect(File.exist?("#{config_path}.lock")).to be(false)
    end
  end
end
