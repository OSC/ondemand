# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::NginxCleanGenerator do
  let(:user) { 'deleted_user' }
  let(:directory) { Dir.mktmpdir('cleanup.recovery-') }
  let(:runtime_root) { File.join(directory, 'run', user) }
  let(:pid_path) { File.join(runtime_root, 'passenger.pid') }
  let(:socket_path) { File.join(runtime_root, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'config', "#{user}.conf") }
  let(:secret_path) { File.join(directory, 'secrets', "#{user}.secret") }
  let(:generator) { described_class.new }

  before do
    [runtime_root, File.dirname(config_path), File.dirname(secret_path)].each { |path| FileUtils.mkdir_p(path) }
    File.write(pid_path, '12345')
    File.write(config_path, 'configuration')
    File.write(secret_path, 'secret')
    allow(NginxStage).to receive(:active_users).and_return([])
    # Keep real inactive-user discovery, including on a fresh cleanup invocation.
    allow(NginxStage).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.pid')
    end
    allow(NginxStage).to receive(:pun_socket_path) do |user:|
      File.join(directory, 'run', user.to_s, 'passenger.sock')
    end
    allow(NginxStage).to receive(:pun_config_path) do |user:|
      File.join(directory, 'config', "#{user}.conf")
    end
    allow(NginxStage).to receive(:pun_secret_key_base_path) do |user:|
      File.join(directory, 'secrets', "#{user}.secret")
    end
    allow(Etc).to receive(:getpwnam).with(user).and_raise(ArgumentError, 'user deleted')
    allow(Process).to receive(:kill).with('TERM', 12_345).and_raise(Errno::ESRCH)
    allow(generator).to receive(:puts)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  # Model account restoration between enumeration and locked cleanup.
  def restore_account
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, user)
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
  end

  [:dead_pid, :successful_shutdown].each do |state|
    [:secret, :config].each do |failed_file|
      it "retries a temporary #{failed_file} deletion error after #{state}" do
        if state == :successful_shutdown
          expect(Process).to receive(:kill).with('TERM', 12_345).once.and_return(1)
          allow(generator).to receive(:wait_for_pun_shutdown) { File.unlink(pid_path) }
        else
          expect(Process).to receive(:kill).with('TERM', 12_345).once.and_raise(Errno::ESRCH)
        end
        target = failed_file == :secret ? secret_path : config_path
        fail_once = true
        allow(FileUtils).to receive(:rm).and_wrap_original do |original, path|
          if path == target && fail_once
            fail_once = false
            raise Errno::EACCES, path
          end
          original.call(path)
        end

        expect { generator.invoke }.to output(/Permission denied/).to_stderr
        expect(File.exist?(pid_path)).to be(false)
        expect(NginxStage.inactive_users).to eq([user])

        # The permission failure is resolved; a new generator must rediscover it.
        retry_cleanup = described_class.new
        allow(retry_cleanup).to receive(:puts)
        expect { retry_cleanup.invoke }.not_to output.to_stderr

        expect(File.exist?(config_path)).to be(false)
        expect(File.exist?(secret_path)).to be(false)
        expect(File.exist?(runtime_root)).to be(false)
        expect(NginxStage.inactive_users).to eq([])
      end
    end
  end

  [:config, :secret, :runtime_directory].each do |remaining|
    it "discovers and removes a leftover #{remaining} without a PID file" do
      File.unlink(pid_path)
      File.unlink(config_path) unless remaining == :config
      File.unlink(secret_path) unless remaining == :secret
      FileUtils.rmdir(runtime_root) unless remaining == :runtime_directory
      expect(Process).not_to receive(:kill)
      expect(NginxStage.inactive_users).to eq([user])

      expect { generator.invoke }.not_to output.to_stderr

      expect(File.exist?(config_path)).to be(false)
      expect(File.exist?(secret_path)).to be(false)
      expect(File.exist?(runtime_root)).to be(false)
      expect(NginxStage.inactive_users).to eq([])
    end
  end

  it 'rediscovers an empty runtime directory after its temporary removal failure' do
    fail_once = true
    allow(FileUtils).to receive(:rmdir).and_wrap_original do |original, path|
      if path.to_s == runtime_root && fail_once
        fail_once = false
        raise Errno::EACCES, path.to_s
      end
      original.call(path)
    end

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
    expect(File.exist?(pid_path)).to be(false)
    expect(File.exist?(config_path)).to be(false)
    expect(File.exist?(secret_path)).to be(false)
    expect(NginxStage.inactive_users).to eq([user])

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.exist?(runtime_root)).to be(false)
  end

  [:ordinary_file, :dangling_symlink].each do |entry|
    it "preserves residual files beside an occupied socket #{entry} without a PID" do
      File.unlink(pid_path)
      if entry == :ordinary_file
        File.write(socket_path, 'unknown owner')
      else
        File.symlink(File.join(directory, 'missing-target'), socket_path)
      end
      expect(Process).not_to receive(:kill)
      expect(FileUtils).not_to receive(:rm)
      expect(FileUtils).not_to receive(:rmdir)

      expect { generator.invoke }.to output(/PID or socket path still exists/).to_stderr
      expect(File.read(config_path)).to eq('configuration')
      expect(File.read(secret_path)).to eq('secret')
      expect(File.exist?(socket_path) || File.symlink?(socket_path)).to be(true)
    end
  end

  it 'preserves a dangling PID symlink and residual metadata' do
    File.unlink(pid_path)
    File.symlink(File.join(directory, 'missing-target'), pid_path)
    expect(Process).not_to receive(:kill)
    expect(FileUtils).not_to receive(:rm)

    expect { generator.invoke }.to output(/PID or socket path still exists/).to_stderr
    expect(File.symlink?(pid_path)).to be(true)
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'skips an account restored while waiting for the lifecycle lock' do
    allow(generator).to receive(:with_pun_lifecycle_lock).and_wrap_original do |original, **args, &block|
      original.call(**args) do
        restore_account
        block.call
      end
    end
    expect(Process).not_to receive(:kill)
    expect(FileUtils).not_to receive(:rm)
    expect(FileUtils).not_to receive(:rmdir)

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(config_path)).to eq('configuration')
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'does not select residual files belonging to a resolvable account' do
    File.unlink(pid_path)
    restore_account
    expect(NginxStage.inactive_users).to eq([])
    expect(generator).not_to receive(:with_pun_lifecycle_lock)

    generator.invoke

    expect(File.read(config_path)).to eq('configuration')
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'preserves orphaned state and avoids locking with --skip-nginx' do
    File.unlink(pid_path)
    dry_run = described_class.new(skip_nginx: true)
    expect(Process).not_to receive(:kill)
    expect(FileUtils).not_to receive(:rm)
    expect(FileUtils).not_to receive(:rmdir)

    expect { dry_run.invoke }.to output("#{user} (disabled)\n").to_stdout
    expect(File.exist?("#{config_path}.lock")).to be(false)
    expect(File.read(config_path)).to eq('configuration')
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'leaves another user\'s orphaned state alone with --user' do
    File.unlink(pid_path)
    targeted = described_class.new(user: 'another_user')
    expect(targeted).not_to receive(:with_pun_lifecycle_lock)
    expect(Process).not_to receive(:kill)
    expect(FileUtils).not_to receive(:rm)
    expect(FileUtils).not_to receive(:rmdir)

    expect { targeted.invoke }.not_to output.to_stdout
    expect(File.read(config_path)).to eq('configuration')
    expect(File.read(secret_path)).to eq('secret')
  end

  it 'requires repeated user fields in configured paths to identify the same account' do
    File.unlink(pid_path)
    File.unlink(config_path)
    File.unlink(secret_path)
    FileUtils.rmdir(runtime_root)
    allow(NginxStage).to receive(:pun_config_path) do |user:|
      File.join(directory, 'repeated', user.to_s, "#{user}.conf")
    end
    FileUtils.mkdir_p(File.join(directory, 'repeated', user))
    File.write(File.join(directory, 'repeated', user, 'another_user.conf'), 'unrelated')

    expect(NginxStage.inactive_users).to eq([])

    File.write(File.join(directory, 'repeated', user, "#{user}.conf"), 'configuration')
    expect(NginxStage.inactive_users).to eq([user])
  end
end
