# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'timeout'

describe NginxStage::Generator do
  let(:test_user) { 'spec' }
  let(:directory) { Dir.mktmpdir('pun-lifecycle-spec') }
  let(:config_path) { File.join(directory, 'spec.conf') }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell)
                   .new(1000, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, test_user)
    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  it 'blocks startup until app shutdown, socket cleanup, and replacement start finish' do
    app = NginxStage::AppConfigGenerator.new(user: test_user, sub_request: '/sys/dashboard')
    startup = NginxStage::PunConfigGenerator.new(user: test_user)
    events = Queue.new
    waiting_for_socket = Queue.new
    finish_shutdown = Queue.new
    startup_attempted = Queue.new
    status = instance_double(Process::Status, success?: true)

    allow(NginxStage).to receive_messages(
      pun_config_path: config_path,
      pun_pid_path:    '/tmp/pun-lifecycle-spec.pid',
      nginx_bin:       '/usr/sbin/nginx'
    )
    allow(File).to receive(:file?).and_call_original
    allow(File).to receive(:file?).with('/tmp/pun-lifecycle-spec.pid').and_return(true)
    allow(NginxStage::PidFile).to receive(:new)
      .with('/tmp/pun-lifecycle-spec.pid').and_return(instance_double(NginxStage::PidFile))
    allow(app).to receive(:pun_running?).and_return(true, false)
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(NginxStage).to receive(:nginx_args)
      .with(user: app.user, signal: :stop).and_return(['stop'])
    allow(NginxStage).to receive(:nginx_args)
      .with(user: app.user).and_return(['start'])
    allow(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: anything, user: app.user, signal: :stop) do
        events << :stop
        ['', status]
      end
    allow(Open3).to receive(:capture2e)
      .with(['/usr/sbin/nginx', '(spec)'], 'start') do
        events << :replacement_start
        ['', status]
      end
    allow(app).to receive(:wait_for_pun_shutdown).with(user: app.user) do
      waiting_for_socket << true
      finish_shutdown.pop
      events << :socket_removed
    end
    allow(NginxStage::AppConfigGenerator).to receive(:hooks).and_return(
      exec_nginx: NginxStage::AppConfigGenerator.hooks.fetch(:exec_nginx)
    )
    allow(NginxStage::PunConfigGenerator).to receive(:hooks).and_return(
      setup_probe: proc { events << :startup_setup }
    )
    allow(startup).to receive(:with_pun_lifecycle_lock).and_wrap_original do |original, **args, &block|
      startup_attempted << true
      original.call(**args, &block)
    end

    begin
      app_thread = Thread.new do
        app.invoke
      rescue SystemExit => e
        e.status
      end
      Timeout.timeout(5) { waiting_for_socket.pop }
      startup_thread = Thread.new { startup.invoke }
      Timeout.timeout(5) { startup_attempted.pop }

      # The startup must remain blocked while the app owns the real flock.
      expect(startup_thread.join(0.05)).to be_nil
      finish_shutdown << true
      expect(app_thread.join(5)).not_to be_nil
      expect(app_thread.value).to eq(0)
      expect(startup_thread.join(5)).not_to be_nil
      observed_events = Timeout.timeout(5) { 4.times.map { events.pop } }
      expect(observed_events).to eq(
        [:stop, :socket_removed, :replacement_start, :startup_setup]
      )
    ensure
      finish_shutdown << true
      [app_thread, startup_thread].compact.each do |thread|
        thread.kill if thread.alive?
        thread.join
      end
    end
  end

  it 'preserves the blocked-startup error and releases the shared lock after it' do
    startup = NginxStage::PunConfigGenerator.new(user: test_user)
    allow(NginxStage).to receive(:pun_config_path).and_return(config_path)
    allow(startup).to receive(:pun_running?).and_return(true)
    allow(NginxStage::PunConfigGenerator).to receive(:hooks).and_return(
      skip_running_pun: NginxStage::PunConfigGenerator.hooks.fetch(:skip_running_pun)
    )

    expect { startup.invoke }
      .to raise_error(NginxStage::Error, 'Startup blocked because a PUN is already running')
    File.open("#{config_path}.lock", File::RDWR) do |lock|
      expect(lock.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
    end
  end
end
