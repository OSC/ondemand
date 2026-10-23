# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'rbconfig'
require 'tmpdir'
require_relative '../support/pun_native_environment'

# A controlled executable with an nginx title exercises real procfs and kernel
# signals. This tests API plumbing, not nginx/Passenger drain behavior.
RSpec.describe NginxStage::PunProcess, :native do
  include PunNativeEnvironment

  let(:directory) { Dir.mktmpdir('pun-native') }
  let(:binary) { File.join(directory, 'nginx') }
  let(:other_binary) { File.join(directory, 'other') }
  let(:pid_path) { File.join(directory, 'pun.pid') }
  let(:user) { 'spec' }
  let(:source) { ['/bin/cat', '/usr/bin/cat'].find { |path| File.executable?(path) } }

  def master_title(name)
    "nginx: master process (#{name}) -c /trusted/#{name}.conf"
  end

  def start_native_child(title, executable: binary)
    reader, writer = IO.pipe
    pid = Process.spawn([executable, title], in: reader, out: File::NULL, err: File::NULL, rlimit_core: 0)
    track_child(pid, writer)
    wait_until { File.binread("/proc/#{pid}/cmdline").sub(/\x00+\z/, '') == title }
    File.write(pid_path, pid.to_s)
    pid
  ensure
    reader&.close unless reader&.closed?
    writer&.close unless pid || writer&.closed?
  end

  def pun
    described_class.new(pid: NginxStage::PidFile.new(pid_path).pid, user: user)
  end

  before do
    require_native_signaling!
    native_requirement!(source, 'requires a controlled cat executable')
    [binary, other_binary].each do |destination|
      FileUtils.cp(source, destination)
      File.chmod(0o755, destination)
    end
    native_requirement!(File.executable?(binary), 'fixture directory must allow executable files')
    allow(NginxStage).to receive(:nginx_bin).and_return(binary)
    allow(NginxStage).to receive(:nginx_args) { |user:| ['-c', "/trusted/#{user}.conf"] }
  end

  after do
    cleanup_children
    FileUtils.remove_entry(directory)
  end

  { stop: 'TERM', quit: 'QUIT', reload: 'HUP', reopen: 'USR1' }.each do |operation, signal|
    it "delivers #{operation} to its verified child through the real kernel API" do
      pid = start_native_child(master_title(user))
      expect(pun.state).to eq(:matching)
      pun.signal(operation)
      status = await_child(pid)
      expect(status).to be_signaled
      expect(Signal.signame(status.termsig)).to eq(signal)
    end
  end

  [:unlinked, :old, :dpkg_tmp].each do |replacement|
    it "recognizes and stops a master after #{replacement} executable replacement" do
      pid = start_native_child(master_title(user))
      case replacement
      when :unlinked
        File.unlink(binary)
      when :old
        File.rename(binary, "#{binary}.old")
      when :dpkg_tmp
        File.rename(binary, "#{binary}.dpkg-tmp")
      end
      FileUtils.cp(source, binary)
      File.chmod(0o755, binary)
      expect(pun.state).to eq(:matching)
      pun.signal(:stop)
      expect(Signal.signame(await_child(pid).termsig)).to eq('TERM')
    end
  end

  it 'recognizes a zombie before reaping, then reports the reaped child as dead' do
    pid = start_native_child(master_title(user))
    Process.kill('KILL', pid)
    wait_until { File.read("/proc/#{pid}/stat").split(') ').last.start_with?('Z') }
    expect(pun.state).to eq(:dead)
    expect { pun.signal(:stop) }.to raise_error(Errno::ESRCH)
    expect(Signal.signame(await_child(pid).termsig)).to eq('KILL')
    # Query only: never signal a numeric PID after its child has been reaped.
    expect(described_class.state(pid_file: NginxStage::PidFile.new(pid_path), user: user)).to eq(:dead)
  end

  [
    'nginx: worker process',
    'nginx: master process (other.user-name@example.org) -c /trusted/other.user-name@example.org.conf'
  ].each do |title|
    it "leaves a real foreign nginx role running: #{title.inspect}" do
      pid = start_native_child(title)
      expect(pun.state).to eq(:foreign)
      expect { pun.signal(:stop) }.to raise_error(NginxStage::Error, /identity is foreign/)
      expect(child_running?(pid)).to be(true)
    end
  end

  it 'leaves an unrelated live executable running' do
    pid = start_native_child('unrelated daemon', executable: other_binary)
    expect(pun.state).to eq(:foreign)
    expect { pun.signal(:stop) }.to raise_error(NginxStage::Error, /identity is foreign/)
    expect(child_running?(pid)).to be(true)
  end

  it 'preserves a live child with an uncertain nginx role' do
    pid = start_native_child('nginx: cache manager process')
    expect(pun.state).to eq(:unknown)
    expect { pun.signal(:stop) }.to raise_error(NginxStage::Error, /identity is unknown/)
    expect(child_running?(pid)).to be(true)
  end

  it 'classifies a visible kernel thread without ever signaling it' do
    thread = Dir.children('/proc').select { |name| /\A\d+\z/.match?(name) }.find do |name|
      flags = File.read("/proc/#{name}/stat").split(') ').last.split[6]
      flags && (Integer(flags) & described_class::PF_KTHREAD).nonzero?
    rescue SystemCallError, ArgumentError
      false
    end
    native_requirement!(thread, 'no kernel thread is visible in this PID namespace')
    expect(Kernel).not_to receive(:syscall)
    expect(described_class.new(pid: thread.to_i, user: user).state).to eq(:foreign)
  end
end
