# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'socket'
require 'tmpdir'
require_relative '../support/pun_native_environment'

RSpec.describe NginxStage::SocketProbe, :native do
  include PunNativeEnvironment

  let(:directory) { Dir.mktmpdir('pun-sock') }
  let(:path) { File.join(directory, 'pun.sock') }

  def stale_socket(at = path)
    UNIXServer.new(at).close
    expect(File.socket?(at)).to be(true)
  end

  before do
    require_native_sockets!(directory)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'preserves a real listener and closes the probe connection' do
    server = UNIXServer.new(path)
    probe = described_class.new(path)
    expect(probe.state).to eq(:listening)
    expect(probe.remove_stale).to be(false)
    expect(File.socket?(path)).to be(true)
    connection = server.accept_nonblock(exception: false)
    expect(connection).to be_a(UNIXSocket)
    expect(Timeout.timeout(5) { connection.read(1) }).to be_nil
  ensure
    connection.close if connection.respond_to?(:close)
    server&.close
  end

  it 'removes an actual stale socket after its listener closes' do
    stale_socket
    probe = described_class.new(path)
    expect(probe.state).to eq(:stale)
    expect(probe.remove_stale).to be(true)
    expect(File.exist?(path)).to be(false)
  end

  it 'preserves a listener when its real connection backlog is full' do
    native_requirement!(RUBY_PLATFORM.include?('linux'), 'requires Linux Unix-socket backlog semantics')
    server = Socket.new(:UNIX, :STREAM)
    server.bind(Socket.sockaddr_un(path))
    server.listen(0)
    clients = []
    full = false
    64.times do
      client = Socket.new(:UNIX, :STREAM)
      clients << client
      result = client.connect_nonblock(Socket.sockaddr_un(path), exception: false)
      next if result.eql?(0)

      full = true
      break
    rescue Errno::EAGAIN
      full = true
      break
    end
    native_requirement!(full, 'could not fill the Unix socket backlog')
    probe = described_class.new(path)
    expect(probe.state).to eq(:uncertain)
    expect(probe.remove_stale).to be(false)
    expect(File.socket?(path)).to be(true)
  ensure
    clients&.each(&:close)
    server&.close
  end

  it 'preserves a symlink pointing to an actual stale socket' do
    target = File.join(directory, 'target.sock')
    stale_socket(target)
    File.symlink(target, path)
    probe = described_class.new(path)
    expect(probe.state).to eq(:uncertain)
    expect(probe.remove_stale).to be(false)
    expect(File.symlink?(path)).to be(true)
    expect(File.socket?(target)).to be(true)
  end

  it 'preserves a new listener that replaces a probed stale socket' do
    stale_socket
    probe = described_class.new(path)
    expect(probe.state).to eq(:stale)
    replacement = File.join(directory, 'replacement.sock')
    server = UNIXServer.new(replacement)
    # Keep both inodes allocated so immediate inode reuse cannot mask a change.
    File.rename(replacement, path)
    expect(probe.remove_stale).to be(false)
    expect(described_class.new(path).state).to eq(:listening)
  ensure
    server&.close
  end
end
