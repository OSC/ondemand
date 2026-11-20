# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'socket'

describe 'nginx_clean stale state' do
  let(:dir) { Dir.mktmpdir }
  let(:run_dir) { File.join(dir, 'run') }
  let(:pid_path) { File.join(run_dir, 'passenger.pid') }
  let(:socket_path) { File.join(run_dir, 'passenger.sock') }
  let(:config_path) { File.join(dir, 'spec.conf') }
  let(:secret_path) { File.join(dir, 'spec.secret') }
  let(:generator) { NginxStage::NginxCleanGenerator.new(force: true) }

  before do
    FileUtils.mkdir_p(run_dir)
    File.write(pid_path, '4242')
    File.write(config_path, '')
    File.write(secret_path, '')
    allow(NginxStage).to receive(:pun_pid_path).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).and_return(config_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).and_return(secret_path)
    allow(NginxStage).to receive(:active_users).and_return(['spec'])
    allow(NginxStage).to receive(:inactive_users).and_return([])
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(Process).to receive(:getpgid).with(4242).and_raise(Errno::ESRCH)
    allow(generator).to receive(:session_count).and_return(0)
  end

  after { FileUtils.remove_entry(dir) }

  it 'removes a stale PID when the socket is already absent' do
    expect(Open3).not_to receive(:capture2e)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'still signals a live PUN when its socket is absent' do
    allow(Process).to receive(:getpgid).with(4242).and_return(4242)
    status = instance_double(Process::Status, success?: true)
    expect(Open3).to receive(:capture2e) do
      File.delete(pid_path)
      ['', status]
    end

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
  end

  it 'removes an abandoned socket file that nothing is listening on' do
    UNIXServer.new(socket_path).close
    expect(File.socket?(socket_path)).to be(true)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect([pid_path, socket_path].any? { |path| File.exist?(path) }).to be(false)
  rescue NotImplementedError, Errno::EAFNOSUPPORT, Errno::EPERM => e
    skip "AF_UNIX sockets are unavailable (#{e.class})"
  end

  it 'keeps the PID file when the socket cannot be removed' do
    allow(File).to receive(:delete).and_call_original
    allow(File).to receive(:delete).with(socket_path).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
    expect(File.exist?(pid_path)).to be(true)
  end

  it 'retries disabled-user cleanup after a config removal failure' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    expect(generator).not_to receive('`')
    allow(File).to receive(:delete).and_call_original
    allow(File).to receive(:delete).with(config_path).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Error trying to clean up disabled user gone: Permission denied/).to_stderr
      .and output("gone (disabled)\n").to_stdout
    expect(File.exist?(pid_path)).to be(true)
    expect(File.exist?(secret_path)).to be(false)

    allow(File).to receive(:delete).with(config_path).and_call_original
    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
    expect([run_dir, config_path].any? { |path| File.exist?(path) }).to be(false)
  end
end
