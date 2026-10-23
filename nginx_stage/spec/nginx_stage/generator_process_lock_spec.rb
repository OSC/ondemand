# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'rbconfig'
require_relative '../support/pun_owned_processes'

RSpec.describe NginxStage::Generator do
  include PunOwnedProcesses

  let(:directory) { Dir.mktmpdir('pun-process-lock') }
  let(:user) { 'spec' }
  let(:config_path) { File.join(directory, 'config', 'spec.conf') }
  let(:lock_path) { "#{config_path}.lock" }
  let(:generator) { described_class.new }

  before do
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
  end

  after do
    cleanup_children
    FileUtils.remove_entry(directory)
  end

  it 'excludes another process until the lock holder exits' do
    native_requirement!(Process.respond_to?(:fork), 'requires fork')
    ready_reader, ready_writer = IO.pipe
    release_reader, release_writer = IO.pipe
    pid = fork do
      ready_reader.close
      release_writer.close
      begin
        generator.send(:with_pun_lifecycle_lock, user: user) do
          ready_writer.write('L')
          ready_writer.flush
          release_reader.read(1)
        end
        exit! 0
      rescue StandardError
        exit! 1
      end
    end
    track_child(pid)
    ready_writer.close
    release_reader.close

    expect(Timeout.timeout(5) { ready_reader.read(1) }).to eq('L')
    File.open(lock_path, File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
    end
    release_writer.close
    expect(await_child(pid)).to be_success
    File.open(lock_path, File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
    end
  ensure
    [ready_reader, ready_writer, release_reader, release_writer].compact.each do |stream|
      stream.close unless stream.closed?
    end
  end

  it 'does not pass its lifecycle lock descriptor into the executable it starts' do
    native_requirement!(File.directory?('/proc/self/fd'), 'requires procfs descriptor inspection')
    fake_nginx = File.join(directory, 'nginx')
    File.write(fake_nginx, "#!#{RbConfig.ruby}\n#{<<~'RUBY'}")
      lock_path = File.realpath(ARGV.fetch(0))
      inherited = Dir.children('/proc/self/fd').any? do |fd|
        File.readlink("/proc/self/fd/#{fd}") == lock_path
      rescue SystemCallError
        false
      end
      print(inherited ? 'inherited' : 'not inherited')
    RUBY
    File.chmod(0o755, fake_nginx)
    allow(NginxStage).to receive_messages(
      nginx_bin: fake_nginx, pun_pid_path: File.join(directory, 'absent.pid'),
      pun_socket_path: File.join(directory, 'absent.sock')
    )
    allow(NginxStage).to receive(:nginx_args).with(user: user).and_return([lock_path])
    allow(NginxStage).to receive(:clean_nginx_env).with(user: user)

    output, status = generator.send(:with_pun_lifecycle_lock, user: user) do
      generator.send(:run_nginx, user: user)
    end
    expect(status).to be_success
    expect(output).to eq('not inherited')
  end
end
