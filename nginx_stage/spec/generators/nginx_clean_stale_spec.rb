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

  # Model only the socket probe: native AF_UNIX calls are unavailable in the
  # local review runtime. Beaker exercises cleanup on the target host.
  def socket_probe(error = nil)
    File.write(socket_path, '')
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(socket_path).and_return(true)
    socket = instance_double(Socket)
    if error
      allow(socket).to receive(:connect_nonblock).and_raise(error)
    else
      allow(socket).to receive(:connect_nonblock).and_return(0)
    end
    allow(Socket).to receive(:open).with(Socket::AF_UNIX, Socket::SOCK_STREAM, 0).and_yield(socket)
  end

  it 'removes a stale PID when the socket is already absent' do
    expect(Open3).not_to receive(:capture2e)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'still signals a live PUN when its socket is absent' do
    allow(Process).to receive(:getpgid).with(4242).and_return(4242)
    allow(File).to receive(:read).and_call_original
    stat = "4242 (nginx) #{(['S'] + Array.new(18, '0') + ['12345']).join(' ')}"
    allow(File).to receive(:read).with('/proc/4242/stat').and_return(stat)
    allow(File).to receive(:read).with('/proc/4242/cmdline')
      .and_return("nginx: master process (spec) -c #{config_path}\0")
    allow(File).to receive(:identical?).and_call_original
    allow(File).to receive(:identical?).with('/proc/4242/exe', NginxStage.nginx_bin).and_return(true)
    status = instance_double(Process::Status, success?: true)
    expect(Open3).to receive(:capture2e) do
      File.delete(pid_path)
      allow(File).to receive(:read).with('/proc/4242/stat').and_raise(Errno::ENOENT)
      ['', status]
    end

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
  end

  it 'preserves an existing live listener despite a stale PID' do
    socket_probe

    expect { generator.invoke }.to output(/refusing to remove live PUN socket/).to_stderr
    expect([pid_path, socket_path].all? { |path| File.exist?(path) }).to be(true)
  end

  it 'removes an abandoned socket when connecting is refused' do
    socket_probe(Errno::ECONNREFUSED)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect([pid_path, socket_path].any? { |path| File.exist?(path) }).to be(false)
  end

  it 'preserves state when a nonblocking connect is inconclusive' do
    socket_probe(Errno::EAGAIN)

    expect { generator.invoke }.to output(/temporarily unavailable/).to_stderr
    expect([pid_path, socket_path].all? { |path| File.exist?(path) }).to be(true)
  end

  it 'cleans already-dead disabled users without attempting a signal' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    expect(generator).not_to receive('`')
    expect(Process).not_to receive(:kill)

    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
    expect([run_dir, config_path, secret_path].any? { |path| File.exist?(path) }).to be(false)
  end

  it 'tolerates config and secret files already removed by a previous cleanup' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    File.delete(config_path)
    File.delete(secret_path)
    expect(generator).not_to receive('`')

    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
    expect(File.exist?(run_dir)).to be(false)
  end

  it 'preserves disabled-user config when its socket is still live' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    socket_probe

    expect { generator.invoke }.to output(/refusing to remove live PUN socket/).to_stderr
      .and output("gone (disabled)\n").to_stdout
    expect([pid_path, socket_path, config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
  end
end
