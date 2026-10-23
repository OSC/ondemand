# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

RSpec.describe NginxStage::SocketProbe do
  let(:path) { '/trusted/run/user/passenger.sock' }
  let(:stat) { instance_double(File::Stat, socket?: true, dev: 1, ino: 2) }
  let(:socket) { instance_double(Socket, close: nil) }

  before do
    allow(File).to receive(:lstat).with(path).and_return(stat)
    allow(Socket).to receive(:new).with(Socket::AF_UNIX, Socket::SOCK_STREAM, 0).and_return(socket)
    allow(socket).to receive(:connect_nonblock).with(Socket.sockaddr_un(path), exception: false).and_return(0)
  end

  it 'preserves a listening socket and closes the probe connection' do
    expect(socket).to receive(:close).once
    probe = described_class.new(path)
    expect(probe.state).to eq(:listening)
    expect(probe.remove_stale).to be(false)
  end

  it 'removes only the same socket after a refused connection' do
    allow(socket).to receive(:connect_nonblock).and_raise(Errno::ECONNREFUSED)
    expect(socket).to receive(:close).once
    expect(File).to receive(:unlink).with(path).once
    probe = described_class.new(path)
    expect(probe.state).to eq(:stale)
    expect(probe.remove_stale).to be(true)
  end

  [:wait_readable, :wait_writable].each do |wait|
    it "preserves a full backlog or pending connection returning #{wait} without waiting" do
      expect(socket).to receive(:connect_nonblock).once.and_return(wait)
      expect(socket).to receive(:close).once
      probe = described_class.new(path)
      expect(probe.state).to eq(:uncertain)
      expect(probe.remove_stale).to be(false)
    end
  end

  [Errno::EACCES, Errno::EPERM, Errno::EAGAIN, Errno::ENOENT, Errno::EMFILE, IOError].each do |error|
    it "preserves an inconclusive #{error} result and closes the connection" do
      allow(socket).to receive(:connect_nonblock).and_raise(error)
      expect(socket).to receive(:close).once
      probe = described_class.new(path)
      expect(probe.state).to eq(:uncertain)
      expect(probe.remove_stale).to be(false)
    end
  end

  it 'preserves an ordinary file or symlink without connecting' do
    allow(stat).to receive(:socket?).and_return(false)
    expect(Socket).not_to receive(:new)
    expect(File).not_to receive(:unlink)
    expect(described_class.new(path).state).to eq(:uncertain)
  end

  it 'preserves an inaccessible path without connecting' do
    allow(File).to receive(:lstat).with(path).and_raise(Errno::EACCES)
    expect(Socket).not_to receive(:new)
    expect(described_class.new(path).remove_stale).to be(false)
  end

  [:inode, :device, :file_type].each do |change|
    it "preserves a path replaced after probing (#{change})" do
      replacement = instance_double(File::Stat, socket?: change != :file_type,
                                    dev: change == :device ? 3 : 1, ino: change == :inode ? 3 : 2)
      allow(File).to receive(:lstat).with(path).and_return(stat, replacement)
      allow(socket).to receive(:connect_nonblock).and_raise(Errno::ECONNREFUSED)
      expect(File).not_to receive(:unlink)
      expect(described_class.new(path).remove_stale).to be(false)
    end
  end

  it 'accepts an absent socket but preserves a path that appears before removal' do
    allow(File).to receive(:lstat).with(path).and_raise(Errno::ENOENT)
    allow(File).to receive(:exist?).with(path).and_return(true)
    expect(File).not_to receive(:unlink)
    probe = described_class.new(path)
    expect(probe.state).to eq(:absent)
    expect(probe.remove_stale).to be(false)
  end

  it 'preserves the socket if a probe descriptor cannot be allocated' do
    allow(Socket).to receive(:new).and_raise(Errno::EMFILE)
    expect(socket).not_to receive(:close)
    expect(described_class.new(path).remove_stale).to be(false)
  end
end
