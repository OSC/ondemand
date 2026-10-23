# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'timeout'

RSpec.describe NginxStage::PunConfigGenerator do
  let(:directory) { Dir.mktmpdir('pun-two-starts') }
  let(:user) { 'spec' }
  let(:config_path) { File.join(directory, 'spec.conf') }
  let(:secret_path) { File.join(directory, 'spec.secret') }
  let(:pid_path) { File.join(directory, 'pun.pid') }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(Struct.new(:gid, :name).new(1000, user))
    allow(NginxStage).to receive_messages(
      pun_config_path: config_path, pun_pid_path: pid_path,
      pun_socket_path: File.join(directory, 'absent.sock'), nginx_bin: '/usr/sbin/nginx'
    )
    allow(NginxStage).to receive(:nginx_args).and_return(['start'])
    allow(NginxStage).to receive(:clean_nginx_env)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'starts only one PUN and rechecks the queued request before it rewrites metadata' do
    setups = Queue.new
    hooks = described_class.hooks
    # Hooks run in a generator's context; capture the private fixture paths.
    first_config = config_path
    first_secret = secret_path
    setup_hook = proc do
      setups << true
      File.write(first_config, 'first configuration')
      File.write(first_secret, 'first secret')
    end
    # Keep actual validation, state guarding and execution; replace only setup.
    allow(described_class).to receive(:hooks).and_return(
      validate_user_not_special:      hooks.fetch(:validate_user_not_special),
      block_user_with_disabled_shell: hooks.fetch(:block_user_with_disabled_shell),
      skip_running_pun:               hooks.fetch(:skip_running_pun),
      setup_probe:                    setup_hook,
      exec_nginx:                     hooks.fetch(:exec_nginx)
    )
    startups = Array.new(2) { described_class.new(user: user) }
    started = Queue.new
    release_start = Queue.new
    second_attempted = Queue.new
    status = instance_double(Process::Status, success?: true)
    expect(NginxStage::PunProcess).to receive(:state)
      .with(pid_file: have_attributes(pid: 12_345), user: anything).once.and_return(:matching)
    expect(Open3).to receive(:capture2e).with(['/usr/sbin/nginx', '(spec)'], 'start').once do
      started << true
      Timeout.timeout(5) { release_start.pop }
      File.write(pid_path, '12345')
      ['', status]
    end
    allow(startups.last).to receive(:with_pun_lifecycle_lock).and_wrap_original do |original, **args, &block|
      second_attempted << true
      original.call(**args, &block)
    end
    threads = []

    begin
      threads << Thread.new do
        startups.first.invoke
      rescue SystemExit => e
        e.status
      end
      Timeout.timeout(5) { started.pop }
      threads << Thread.new do
        startups.last.invoke
      rescue NginxStage::Error => e
        e
      end
      Timeout.timeout(5) { second_attempted.pop }
      expect(threads.last.join(0.05)).to be_nil
      release_start << true
      threads.each { |thread| expect(thread.join(5)).not_to be_nil }
      expect(threads.first.value).to eq(0)
      expect(threads.last.value).to be_a(NginxStage::Error)
      expect(threads.last.value.message).to eq('Startup blocked because a PUN is already running')
      expect(setups.size).to eq(1)
      expect(File.read(pid_path)).to eq('12345')
      expect(File.read(config_path)).to eq('first configuration')
      expect(File.read(secret_path)).to eq('first secret')
    ensure
      release_start << true
      threads.each { |thread| thread.kill if thread.alive? }
      threads.each(&:join)
    end
  end
end
