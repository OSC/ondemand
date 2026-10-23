# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::PunProcess do
  let(:directory) { Dir.mktmpdir('pun-process-spec') }
  let(:process_root) { File.join(directory, 'process') }
  let(:binary) { File.join(directory, 'nginx') }
  let(:other_binary) { File.join(directory, 'other') }
  let(:process) { described_class.new(pid: 12_345, user: 'spec') }
  let(:handle) { File.open(process_root, File::RDONLY) }
  let(:retired_binaries) { [] }
  let(:title) { 'nginx: master process (spec) -c /trusted/spec.conf' }

  before do
    FileUtils.mkdir_p(process_root)
    File.write(binary, 'nginx executable')
    File.write(other_binary, 'unrelated executable')
    File.symlink(binary, File.join(process_root, 'exe'))
    File.write(File.join(process_root, 'cmdline'), "#{title}\0\0")
    File.write(File.join(process_root, 'stat'), "12345 (nginx) S #{'0 ' * 25}")
    File.write(File.join(process_root, 'status'), "Uid:\t#{Process.euid}\t#{Process.euid}\t0\t0\n")
    handle
    allow(described_class).to receive(:proc_available?).and_return(true)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with('/proc/12345', File::RDONLY).and_yield(handle)
    allow(NginxStage).to receive(:nginx_bin).and_return(binary)
    allow(NginxStage).to receive(:nginx_args) { |user:| ['-c', "/trusted/#{user}.conf"] }
  end

  after do
    retired_binaries.each(&:close)
    handle.close
    FileUtils.remove_entry(directory)
  end

  it 'recognizes the expected executable, master command, config and effective owner' do
    expect(process.state).to eq(:matching)
  end

  it 'recognizes an unrelated executable without relying on its PID being dead' do
    File.unlink(File.join(process_root, 'exe'))
    File.symlink(other_binary, File.join(process_root, 'exe'))
    File.write(File.join(process_root, 'cmdline'), "/usr/bin/sleep\0 10\0")

    expect(process.state).to eq(:foreign)
    expect(Kernel).not_to receive(:syscall)
    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is foreign/)
  end

  [
    'nginx: master process (someone_else) -c /trusted/other.conf',
    'nginx: master process (spec) -c /trusted/spec.conf.extra'
  ].each do |command|
    it "preserves nginx with an unexpected command #{command.inspect}" do
      File.write(File.join(process_root, 'cmdline'), "#{command}\0")

      expect(process.state).to eq(:unknown)
      expect(Kernel).not_to receive(:syscall)
      expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is unknown/)
    end
  end

  [
    'nginx: master process (someone_else) -c /trusted/someone_else.conf',
    'nginx: worker process',
    'nginx: worker process is shutting down'
  ].each do |command|
    it "recognizes another configured master or worker: #{command.inspect}" do
      File.write(File.join(process_root, 'cmdline'), "#{command}\0\0")
      expect(process.state).to eq(:foreign)
      expect(Kernel).not_to receive(:syscall)
      expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is foreign/)
    end

    it "recovers a stale PID reused by #{command.inspect} without signaling it" do
      File.write(File.join(process_root, 'cmdline'), "#{command}\0")
      pid_path = File.join(directory, 'pun.pid')
      config_path = File.join(directory, 'spec.conf')
      File.write(pid_path, '12345')
      File.write(config_path, 'configuration')
      allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
      allow(NginxStage).to receive_messages(
        pun_pid_path: pid_path, pun_config_path: config_path,
        pun_socket_path: File.join(directory, 'absent.sock'),
        active_users: ['spec'], inactive_users: [], pending_cleanup_users: []
      )
      expect(Kernel).not_to receive(:syscall)
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)
      cleaner = NginxStage::NginxCleanGenerator.new(force: true)
      expect { cleaner.invoke }.to output(/stale pid file removed/).to_stderr
      expect(File.exist?(pid_path)).to be(false)
      expect(File.read(config_path)).to eq('configuration')
    end
  end

  it 'recognizes an nginx worker even when it runs with a different effective owner' do
    File.write(File.join(process_root, 'cmdline'), "nginx: worker process\0")
    File.write(File.join(process_root, 'status'), "Uid:\t0\t#{Process.euid + 1}\t0\t0\n")
    expect(process.state).to eq(:foreign)
  end

  it 'preserves a master for another user whose effective owner is unexpected' do
    File.write(File.join(process_root, 'cmdline'), "nginx: master process (other) -c /trusted/other.conf\0")
    File.write(File.join(process_root, 'status'), "Uid:\t0\t#{Process.euid + 1}\t0\t0\n")
    expect(process.state).to eq(:unknown)
  end

  [
    'nginx: worker process extra', 'nginx: cache manager process',
    'nginx: master process (spec) -c /wrong.conf'
  ].each do |command|
    it "preserves an unrecognized nginx role or config: #{command.inspect}" do
      File.write(File.join(process_root, 'cmdline'), "#{command}\0")
      expect(process.state).to eq(:unknown)
    end
  end

  it 'recognizes a kernel thread from proc flags without requiring command or executable metadata' do
    fields = ['S', *Array.new(25, '0')]
    fields[6] = (0x00200000 | 0x00000040).to_s
    File.write(File.join(process_root, 'stat'), "12345 (kworker) #{fields.join(' ')}")
    File.write(File.join(process_root, 'cmdline'), '')
    File.unlink(File.join(process_root, 'exe'))
    expect(process.state).to eq(:foreign)
    expect(Kernel).not_to receive(:syscall)
    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is foreign/)
  end

  ['not-a-number', '-1'].each do |flags|
    it "preserves malformed proc flags #{flags.inspect}" do
      fields = ['S', *Array.new(25, '0')]
      fields[6] = flags
      File.write(File.join(process_root, 'stat'), "12345 (nginx) #{fields.join(' ')}")
      expect(process.state).to eq(:unknown)
    end
  end

  it 'parses stat fields after a command name containing spaces and closing parentheses' do
    File.write(File.join(process_root, 'stat'), "12345 (odd ) command) S #{'0 ' * 25}")
    expect(process.state).to eq(:matching)
  end

  it 'recognizes a trusted nginx upgrade backup while retaining descriptor signaling' do
    File.rename(binary, "#{binary}.old")
    File.unlink(File.join(process_root, 'exe'))
    File.symlink("#{binary}.old", File.join(process_root, 'exe'))
    File.write(binary, 'new nginx executable')

    expect(process.state).to eq(:matching)
    expect(Kernel).to receive(:syscall).with(424, handle.fileno, Signal.list.fetch('QUIT'), 0, 0)
    process.signal(:quit)
  end

  # Fixture /exe follows a real open unlinked inode. Only readlink's kernel
  # '(deleted)' display is simulated; nlink, ownership and permissions are real.
  def replace_running_binary(path = binary)
    retired_binaries << File.open(binary, File::RDONLY)
    File.unlink(binary)
    File.write(binary, 'new nginx executable')
    File.unlink(File.join(process_root, 'exe'))
    File.symlink("/proc/self/fd/#{retired_binaries.last.fileno}", File.join(process_root, 'exe'))
    allow(File).to receive(:readlink).and_call_original
    executable_path = "/proc/self/fd/#{handle.fileno}/exe"
    allow(File).to receive(:readlink).with(executable_path).and_return("#{path} (deleted)")
  end

  { stop: 'TERM', quit: 'QUIT', reload: 'HUP', reopen: 'USR1' }.each do |operation, signal|
    it "can #{operation} a verified master after the binary inode is unlinked and replaced" do
      replace_running_binary

      expect(process.state).to eq(:matching)
      expect(Process).not_to receive(:kill)
      expect(Kernel).to receive(:syscall).with(424, handle.fileno, Signal.list.fetch(signal), 0, 0)
      process.signal(operation)
    end
  end

  it 'recognizes the exact trusted dpkg backup path after replacement' do
    replace_running_binary("#{binary}.dpkg-tmp")
    expect(process.state).to eq(:matching)
  end

  ['nginx.evil', 'somewhere/nginx', 'nginx.old.extra'].each do |name|
    it "rejects an unrelated deleted executable named #{name.inspect}" do
      replace_running_binary(File.join(directory, name))

      expect(process.state).to eq(:unknown)
      expect(Kernel).not_to receive(:syscall)
      expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is unknown/)
    end
  end

  it 'does not interpret a literal deleted suffix on a still-linked file as upgrade provenance' do
    old = "#{binary} (deleted)"
    File.rename(binary, old)
    File.unlink(File.join(process_root, 'exe'))
    File.symlink(old, File.join(process_root, 'exe'))
    File.write(binary, 'new nginx executable')

    expect(process.state).to eq(:unknown)
  end

  it 'rejects a writable retired executable even with the exact master title and deleted path' do
    replace_running_binary
    retired_binaries.last.chmod(0o666)
    expect(process.state).to eq(:unknown)
  end

  it 'rejects retired executable ownership that differs from the configured binary' do
    replace_running_binary
    allow(File).to receive(:stat).and_wrap_original do |original, path|
      stat = original.call(path)
      allow(stat).to receive(:uid).and_return(Process.euid + 1) if path == "/proc/self/fd/#{handle.fileno}/exe"
      stat
    end
    expect(process.state).to eq(:unknown)
  end

  it 'still rejects an upgraded binary with the wrong master title or owner' do
    replace_running_binary
    File.write(File.join(process_root, 'cmdline'), 'nginx: master process (other) -c /somewhere/other.conf')
    expect(process.state).to eq(:unknown)
    File.write(File.join(process_root, 'cmdline'), "#{title}\0")
    File.write(File.join(process_root, 'status'), "Uid:\t0\t#{Process.euid + 1}\t0\t0\n")
    expect(process.state).to eq(:unknown)
  end

  [0, 1, 3].each do |padding|
    it "recognizes a configuration path with spaces and #{padding} trailing NUL bytes" do
      path = '/trusted directory/spec.conf'
      allow(NginxStage).to receive(:nginx_args).with(user: 'spec').and_return(['-c', path])
      File.write(File.join(process_root, 'cmdline'), "nginx: master process (spec) -c #{path}#{"\0" * padding}")
      expect(process.state).to eq(:matching)
    end
  end

  it 'rejects a master command with an unexpected effective owner' do
    File.write(File.join(process_root, 'status'), "Uid:\t0\t#{Process.euid + 1}\t0\t0\n")
    expect(process.state).to eq(:unknown)
  end

  ['', "#{'x' * 16_384}\0"].each do |command|
    it "preserves empty or truncated command state of #{command.bytesize} bytes" do
      File.write(File.join(process_root, 'cmdline'), command)
      expect(process.state).to eq(:unknown)
    end
  end

  it 'treats a zombie as dead before trying to read its missing executable' do
    File.write(File.join(process_root, 'stat'), "12345 (nginx) Z #{'0 ' * 25}")
    File.unlink(File.join(process_root, 'exe'))
    expect(process.state).to eq(:dead)
    expect(Kernel).not_to receive(:syscall)
    expect { process.signal(:stop) }.to raise_error(Errno::ESRCH)
  end

  it 'preserves unreadable executable metadata' do
    allow(File).to receive(:stat).and_call_original
    allow(File).to receive(:stat).with("/proc/self/fd/#{handle.fileno}/exe").and_raise(Errno::EACCES)
    expect(process.state).to eq(:unknown)
  end

  { stop: 'TERM', quit: 'QUIT', reload: 'HUP', reopen: 'USR1' }.each do |operation, signal|
    it "delivers #{operation} through the same verified process descriptor" do
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)
      expect(Kernel).to receive(:syscall).with(424, handle.fileno, Signal.list.fetch(signal), 0, 0)

      process.signal(operation)
    end
  end

  it 'does not retry a numeric PID if the verified process exits before delivery' do
    expect(Kernel).to receive(:syscall).once.and_raise(Errno::ESRCH)
    expect(Process).not_to receive(:kill)
    expect { process.signal(:stop) }.to raise_error(Errno::ESRCH)
  end

  it 'fails closed on kernels without descriptor signaling' do
    expect(Kernel).to receive(:syscall).once.and_raise(Errno::ENOSYS)
    expect(Process).not_to receive(:kill)
    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /kernel support/)
  end

  it 'preserves state and refuses signals when procfs cannot identify the PID namespace' do
    allow(described_class).to receive(:proc_available?).and_return(false)
    expect(process.state).to eq(:unknown)
    expect(Kernel).not_to receive(:syscall)
    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /requires Linux/)
  end

  it 'does not classify hidden live processes as dead' do
    allow(File).to receive(:open).with('/proc/12345', File::RDONLY).and_raise(Errno::ENOENT)
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    expect(process.state).to eq(:unknown)
    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /metadata is unavailable/)
  end

  it 'classifies a disappeared process as dead after checking liveness' do
    allow(File).to receive(:open).with('/proc/12345', File::RDONLY).and_raise(Errno::ENOENT)
    allow(Process).to receive(:getpgid).with(12_345).and_raise(Errno::ESRCH)
    expect(process.state).to eq(:dead)
    expect { process.signal(:stop) }.to raise_error(Errno::ESRCH)
  end
end
