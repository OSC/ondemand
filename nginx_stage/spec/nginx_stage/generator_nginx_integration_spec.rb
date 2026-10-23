# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'socket'
require 'tmpdir'
require 'timeout'
require_relative '../support/pun_native_environment'

# Opt in with an absolute nginx executable path. These tests use private paths
# and an owned foreground master; they do not load the site's PUN configuration.
RSpec.describe NginxStage::Generator do
  include PunNativeEnvironment

  let(:runtime) { {} }
  let(:directory) { runtime[:directory] = Dir.mktmpdir('ood-nginx-') }
  let(:binary) { File.join(directory, 'nginx') }
  let(:config) { File.join(directory, 'nginx.conf') }
  let(:pid_path) { File.join(directory, 'nginx.pid') }
  let(:socket_path) { File.join(directory, 'nginx.sock') }
  let(:access_log) { File.join(directory, 'access.log') }
  let(:error_log) { File.join(directory, 'error.log') }
  let(:user) { 'integration' }
  let(:generator) { described_class.new }

  def write_config(body = 'before')
    File.write(File.join(directory, 'payload'), 'x' * 65_536)
    File.write(config, <<~CONFIG)
      daemon off;
      pid #{pid_path};
      error_log #{error_log} notice;
      events { worker_connections 64; }
      http {
        access_log #{access_log};
        client_body_temp_path #{directory}/body;
        proxy_temp_path #{directory}/proxy;
        fastcgi_temp_path #{directory}/fastcgi;
        uwsgi_temp_path #{directory}/uwsgi;
        scgi_temp_path #{directory}/scgi;
        server {
          listen unix:#{socket_path};
          location / { return 200 '#{body}'; }
          location /slow { limit_rate 1k; alias #{directory}/payload; }
        }
      }
    CONFIG
  end

  def response
    Timeout.timeout(5) do
      UNIXSocket.open(socket_path) do |socket|
        socket.write("GET / HTTP/1.0\r\nHost: localhost\r\n\r\n")
        socket.read
      end
    end
  end

  def wait_for_response(body)
    wait_until do
      response.end_with?(body)
    rescue Errno::ENOENT, Errno::ECONNREFUSED, Errno::ECONNRESET
      # The master can publish its PID/socket before workers accept requests.
      false
    end
  end

  def start_master
    log = File.join(directory, 'launcher.log')
    pid = Process.spawn([binary, "(#{user})"], '-c', config,
                        out: log, err: log, pgroup: true)
    track_child(pid)
    runtime[:master] = pid
    wait_until do
      # Keep an exited child unreaped so teardown still owns its process group.
      raise "nginx exited: #{File.read(log)}" if NginxStage::PunProcess.new(pid: pid, user: user).state == :dead

      File.socket?(socket_path) && File.file?(pid_path)
    end
    pid
  end

  before do
    source = require_native_nginx!
    FileUtils.cp(source, binary)
    File.chmod(0o755, binary)
    allow(NginxStage).to receive_messages(nginx_bin: binary, pun_config_path: config,
                                          pun_pid_path: pid_path, pun_socket_path: socket_path)
    File.chmod(0o755, directory)
    write_config
    runtime[:master] = start_master
    wait_for_response('before')
  end

  after do
    # Each foreground master owns a fresh process group. While its leader is
    # unreaped, that group cannot be reused by an unrelated process.
    if runtime[:master] && owned_children.key?(runtime[:master])
      process = NginxStage::PunProcess.new(pid: runtime[:master], user: user)
      if process.state == :matching
        process.signal(:stop)
        await_child(runtime[:master])
      end
    end
  ensure
    # Also clean workers if setup or an assertion failed before normal shutdown.
    owned_children.each_key do |pid|
      Process.kill('KILL', -pid)
    rescue Errno::ESRCH
      nil
    end
    cleanup_children
    FileUtils.remove_entry(runtime[:directory]) if runtime[:directory]
  end

  it 'reloads configuration without replacing the master' do
    write_config('after')
    generator.send(:run_nginx, user: user, signal: :reload)
    wait_for_response('after')
    expect(File.read(pid_path).to_i).to eq(runtime[:master])
  end

  it 'keeps serving the previous configuration after rejecting an invalid reload' do
    File.write(config, "invalid_directive;\n")
    generator.send(:run_nginx, user: user, signal: :reload)
    wait_until { File.read(error_log).include?('unknown directive') }
    expect(response).to end_with('before')
    expect(File.read(pid_path).to_i).to eq(runtime[:master])
  end

  it 'reopens a rotated access log and continues serving' do
    response
    rotated = "#{access_log}.old"
    File.rename(access_log, rotated)
    generator.send(:run_nginx, user: user, signal: :reopen)
    wait_until { File.file?(access_log) }
    wait_until do
      response
      File.size(access_log).positive?
    end
    expect(File.size(rotated)).to be_positive
    expect(File.read(pid_path).to_i).to eq(runtime[:master])
  end

  it 'blocks replacement during a real graceful drain, then recovers after the client closes' do
    client = UNIXSocket.new(socket_path)
    client.write("GET /slow HTTP/1.0\r\nHost: localhost\r\n\r\n")
    header = Timeout.timeout(5) { client.gets("\r\n\r\n") }
    expect(header).to include('200 OK')
    # Keep the request open, but shorten only the controller's deadline.
    stub_const('NginxStage::Generator::PUN_SHUTDOWN_TIMEOUT', 1)
    expect { generator.send(:run_nginx, user: user, signal: :quit) }
      .to raise_error(NginxStage::Error, /timed out/)
    wait_until { !File.exist?(socket_path) }
    expect(NginxStage::PunProcess.new(pid: runtime[:master], user: user).state).to eq(:matching)
    expect(File.read(pid_path).to_i).to eq(runtime[:master])
    expect(generator.send(:pun_running?, user: user)).to be(true)
    expect { generator.send(:run_nginx, user: user) }
      .to raise_error(NginxStage::Error, /already running/)
    client.close
    await_child(runtime[:master])
    expect(File.exist?(pid_path)).to be(false)
    runtime[:master] = start_master
    wait_for_response('before')
    expect(File.read(pid_path).to_i).to eq(runtime[:master])
    generator.send(:run_nginx, user: user, signal: :stop)
    await_child(runtime[:master])
    expect(File.exist?(pid_path)).to be(false)
  ensure
    client&.close unless client&.closed?
  end

  [:stop, :quit].each do |signal|
    it "waits for actual #{signal} shutdown and starts a manageable replacement" do
      generator.send(:run_nginx, user: user, signal: signal)
      await_child(runtime[:master])
      expect(File.exist?(socket_path)).to be(false)
      expect(File.exist?(pid_path)).to be(false)
      expect(generator.send(:pun_running?, user: user)).to be(false)
      runtime[:master] = start_master
      expect(File.read(pid_path).to_i).to eq(runtime[:master])
      wait_for_response('before')
      generator.send(:run_nginx, user: user, signal: :stop)
      await_child(runtime[:master])
      expect(File.exist?(pid_path)).to be(false)
    end
  end

  [:unlinked, :old, :dpkg].each do |upgrade|
    it "keeps a real nginx master manageable across #{upgrade} binary replacement" do
      replacement = "#{binary}.new"
      FileUtils.cp(binary, replacement)
      File.chmod(0o755, replacement)
      case upgrade
      when :unlinked
        File.unlink(binary)
      when :old
        File.rename(binary, "#{binary}.old")
      when :dpkg
        File.link(binary, "#{binary}.dpkg-tmp")
      end
      File.rename(replacement, binary)
      expect(NginxStage::PunProcess.new(pid: runtime[:master], user: user).state).to eq(:matching)
      generator.send(:run_nginx, user: user, signal: :reopen)
      generator.send(:run_nginx, user: user, signal: :stop)
      await_child(runtime[:master])
      expect(File.exist?(pid_path)).to be(false)
      expect(File.exist?(socket_path)).to be(false)
    end
  end

  it 'preserves serving orphaned workers, then recovers only after their listener closes' do
    master = runtime.fetch(:master)
    expect(Process.getpgid(master)).to eq(master)
    # The foreground child remains unreaped throughout group cleanup, reserving
    # its PID/group identity even after the master is killed.
    Process.kill('KILL', master)
    wait_until { NginxStage::PunProcess.new(pid: master, user: user).state == :dead }
    wait_for_response('before')
    allow(NginxStage).to receive_messages(active_users: [user], inactive_users: [], pending_cleanup_users: [])
    [false, true].each do |force|
      cleaner = NginxStage::NginxCleanGenerator.new(force: force)
      expect { cleaner.invoke }.to output(/socket path still exists/).to_stderr
      expect(File.read(pid_path).to_i).to eq(master)
      expect(File.socket?(socket_path)).to be(true)
      expect(response).to end_with('before')
    end
    Process.kill('TERM', -master)
    wait_until { NginxStage::SocketProbe.new(socket_path).state == :stale }
    expect { NginxStage::NginxCleanGenerator.new.invoke }.to output(/stale pid file removed/).to_stderr
    await_child(master)
    expect(File.exist?(pid_path)).to be(false)
    expect(File.exist?(socket_path)).to be(false)
    expect(File.file?(config)).to be(true)
    runtime[:master] = start_master
    wait_for_response('before')
    generator.send(:run_nginx, user: user, signal: :stop)
    await_child(runtime[:master])
  end
end
