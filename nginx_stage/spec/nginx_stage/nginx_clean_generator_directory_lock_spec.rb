# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'timeout'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:user) { 'deleted_user' }
  let(:directory) { Dir.mktmpdir('cleanup-directory-lock-') }
  let(:runtime_root) { File.join(directory, 'run', user) }
  let(:pid_path) { File.join(runtime_root, 'passenger.pid') }
  let(:config_path) { File.join(directory, "#{user}.conf") }
  let(:secret_path) { File.join(directory, "#{user}.secret") }
  let(:lock_path) { "#{config_path}.lock" }
  let(:generator) { described_class.new }

  before do
    FileUtils.mkdir_p(runtime_root)
    File.write(pid_path, '12345')
    File.write(config_path, 'configuration')
    File.write(secret_path, 'secret')
    allow(NginxStage).to receive_messages(active_users: [], inactive_users: [user])
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.pid')
    end
    allow(NginxStage).to receive(:pun_socket_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.sock')
    end
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).with(user: user).and_return(secret_path)
    allow(Etc).to receive(:getpwnam).with(user).and_raise(ArgumentError, 'user deleted')
    allow(Process).to receive(:kill).with('TERM', 12_345).and_raise(Errno::ESRCH)
    allow(generator).to receive(:puts)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  # Check the real flock from an independent file descriptor.
  def expect_lifecycle_lock_held
    File.open(lock_path, File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
    end
  end

  [false, true].each do |retry_directory|
    it "blocks replacement startup through directory removal with retry=#{retry_directory}" do
      events = Queue.new
      startup_attempted = Queue.new
      startup = nil
      transient = File.join(runtime_root, 'passenger-cleanup')
      File.write(transient, 'pending') if retry_directory
      start_competitor = lambda do
        startup = Thread.new do
          startup_attempted << true
          # Model the same locked filesystem steps as a re-enabled PUN startup.
          NginxStage::Generator.new.send(:with_pun_lifecycle_lock, user: user) do
            FileUtils.mkdir_p(runtime_root)
            File.write(pid_path, '23456')
            events << :replacement_pid_written
          end
        end
        Timeout.timeout(5) { startup_attempted.pop }
        expect(startup.join(0.05)).to be_nil
      end
      if retry_directory
        expect(generator).to receive(:sleep).with(0.5).once do
          expect_lifecycle_lock_held
          start_competitor.call
          File.unlink(transient)
        end
      end
      allow(FileUtils).to receive(:rmdir).and_wrap_original do |original, path|
        if path.to_s == runtime_root
          expect_lifecycle_lock_held
          start_competitor.call unless retry_directory
          result = original.call(path)
          events << :directory_removed
          result
        else
          original.call(path)
        end
      end

      begin
        generator.invoke
        expect(startup.join(5)).not_to be_nil
        startup.value
        observed = Timeout.timeout(5) { 2.times.map { events.pop } }
        expect(observed).to eq([:directory_removed, :replacement_pid_written])
        expect(File.read(pid_path)).to eq('23456')
        expect(File.exist?(lock_path)).to be(true)
      ensure
        startup&.kill if startup&.alive?
        startup&.join
      end
    end
  end

  it 'releases the lifecycle lock and retains the directory after a removal error' do
    allow(FileUtils).to receive(:rmdir).and_wrap_original do |original, path|
      if path.to_s == runtime_root
        expect_lifecycle_lock_held
        raise Errno::EACCES, path.to_s
      end
      original.call(path)
    end

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
    expect(File.directory?(runtime_root)).to be(true)
    File.open(lock_path, File::RDWR) do |competitor|
      expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
    end
  end

  it 'tolerates a directory disappearing before the locked retry' do
    transient = File.join(runtime_root, 'passenger-cleanup')
    File.write(transient, 'pending')
    expect(generator).to receive(:sleep).with(0.5).once do
      expect_lifecycle_lock_held
      File.unlink(transient)
      Dir.rmdir(runtime_root)
    end
    expect(FileUtils).to receive(:rmdir).with(Pathname.new(runtime_root)).twice.and_call_original

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.exist?(runtime_root)).to be(false)
  end

  it 'preserves unrelated directory contents after both locked removal attempts fail' do
    unrelated = File.join(runtime_root, 'unrelated-file')
    File.write(unrelated, 'preserve')
    expect(generator).to receive(:sleep).with(0.5).once do
      expect_lifecycle_lock_held
    end
    attempts = 0
    allow(FileUtils).to receive(:rmdir).and_wrap_original do |original, path|
      if path.to_s == runtime_root
        expect_lifecycle_lock_held
        attempts += 1
      end
      original.call(path)
    end

    expect { generator.invoke }.to output(/Directory not empty/).to_stderr
    expect(attempts).to eq(2)
    expect(File.read(unrelated)).to eq('preserve')
  end

  it 'keeps a shared PID directory that cannot be protected by one user lock' do
    File.unlink(pid_path)
    shared = File.join(directory, 'shared')
    FileUtils.mkdir_p(shared)
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(shared, "#{user}.pid")
    end
    File.write(File.join(shared, "#{user}.pid"), '12345')
    expect(FileUtils).not_to receive(:rmdir)

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.directory?(shared)).to be(true)
    expect(File.exist?(File.join(shared, "#{user}.pid"))).to be(false)
    expect(File.exist?(config_path)).to be(false)
    expect(File.exist?(secret_path)).to be(false)
  end
end
