# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'
require 'socket'

describe 'nginx_clean stale state' do
  let(:dir) { Dir.mktmpdir }
  let(:run_dir) { File.join(dir, 'run') }
  let(:pid_path) { File.join(run_dir, 'passenger.pid') }
  let(:socket_path) { File.join(run_dir, 'passenger.sock') }
  let(:config_path) { File.join(dir, 'spec.conf') }
  let(:secret_path) { File.join(dir, 'spec.secret') }
  let(:generator) { NginxStage::NginxCleanGenerator.new(force: true) }

  before do
    FileUtils.mkdir_p(run_dir)
    File.write(pid_path, '4242')
    File.write(config_path, '')
    File.write(secret_path, '')
    allow(NginxStage).to receive(:pun_pid_path).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).and_return(config_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).and_return(secret_path)
    allow(NginxStage).to receive(:active_users).and_return(['spec'])
    allow(NginxStage).to receive(:inactive_users).and_return([])
    allow(Process).to receive(:getpgid).with(4242).and_raise(Errno::ESRCH)
    allow(generator).to receive(:session_count).and_return(0)
  end

  after { FileUtils.remove_entry(dir) }

  def stub_live_pid(title: "nginx: master process (spec) -c #{config_path}", executable_matches: true)
    allow(Process).to receive(:getpgid).with(4242).and_return(4242)
    allow(File).to receive(:binread).and_call_original
    allow(File).to receive(:binread).with('/proc/4242/cmdline').and_return("#{title}\0")
    allow(File).to receive(:binread).with('/proc/4242/stat').and_return("4242 (nginx) S #{'0 ' * 18}123")
    allow(File).to receive(:identical?).with('/proc/4242/exe', NginxStage.nginx_bin).and_return(executable_matches)
  end

  it 'removes a stale PID when the socket is already absent' do
    expect(Process).not_to receive(:kill)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'still signals a live PUN when its socket is absent' do
    stub_live_pid
    expect(Process).to receive(:kill).with('TERM', 4242)

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
  end

  it 'preserves the PID file when the PID points to a different PUN' do
    stub_live_pid(title: "nginx: master process (spec) -c #{config_path}.other")
    expect(Process).not_to receive(:kill)

    expect { generator.invoke }.to output(/refusing to signal unverified PUN process 4242/).to_stderr
      .and output('').to_stdout
    expect(File.exist?(pid_path)).to be(true)
  end

  it 'preserves disabled-user state when the executable does not match' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    stub_live_pid(executable_matches: false)
    expect(Process).not_to receive(:kill)

    expect { generator.invoke }.to output(/refusing to signal unverified PUN process 4242/).to_stderr
      .and output("gone (disabled)\n").to_stdout
    expect([pid_path, config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
  end

  it 'accepts a verified master whose executable was replaced during an upgrade' do
    stub_live_pid(executable_matches: false)
    allow(File).to receive(:realpath).and_call_original
    allow(File).to receive(:realpath).with(NginxStage.nginx_bin).and_return('/trusted/nginx')
    allow(File).to receive(:readlink).with('/proc/4242/exe').and_return('/trusted/nginx (deleted)')
    expect(Process).to receive(:kill).with('TERM', 4242)

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
  end

  it 'reads the PID file only after acquiring the startup lock' do
    expect(NginxStage).to receive(:with_pun_start_lock).with(user: 'spec') do |&cleanup|
      File.write(pid_path, '4243')
      cleanup.call
    end
    allow(Process).to receive(:getpgid).with(4243).and_return(4243)
    allow(generator).to receive(:session_count).and_return(1)
    allow(generator).to receive(:force).and_return(false)

    expect { generator.invoke }.to output('').to_stdout.and output('').to_stderr
    expect(File.read(pid_path)).to eq('4243')
  end

  it 'does not signal a PID that was reused during verification' do
    stub_live_pid
    allow(File).to receive(:binread).with('/proc/4242/stat')
      .and_return("4242 (nginx) S #{'0 ' * 18}123", "4242 (nginx) S #{'0 ' * 18}456")
    expect(Process).not_to receive(:kill)

    expect { generator.invoke }.to output(/refusing to signal unverified PUN process 4242/).to_stderr
  end

  it 'preserves a live listener when the PID is stale' do
    listener = UNIXServer.new(socket_path)

    expect { generator.invoke }.to output(/refusing to remove live PUN socket/).to_stderr
    expect(File.socket?(socket_path)).to be(true)
    expect(File.exist?(pid_path)).to be(true)
  rescue NotImplementedError, Errno::EAFNOSUPPORT, Errno::EPERM => e
    skip "AF_UNIX sockets are unavailable (#{e.class})"
  ensure
    listener&.close
  end

  it 'removes an abandoned socket file that nothing is listening on' do
    UNIXServer.new(socket_path).close
    expect(File.socket?(socket_path)).to be(true)

    expect { generator.invoke }.to output(/stale pid file removed/).to_stderr.and output("spec\n").to_stdout
    expect([pid_path, socket_path].any? { |path| File.exist?(path) }).to be(false)
  rescue NotImplementedError, Errno::EAFNOSUPPORT, Errno::EPERM => e
    skip "AF_UNIX sockets are unavailable (#{e.class})"
  end

  it 'leaves the PID and socket in place when the probe is inconclusive' do
    socket = instance_double(Socket, close: nil)
    allow(Socket).to receive(:new).with(:UNIX, :STREAM).and_return(socket)
    allow(socket).to receive(:connect_nonblock).and_raise(Errno::EAGAIN)
    allow(File).to receive(:lstat).and_call_original
    allow(File).to receive(:lstat).with(socket_path).and_return(instance_double(File::Stat, socket?: true))
    expect(File).not_to receive(:delete).with(socket_path)

    expect { generator.invoke }.to output(/#{Regexp.escape(Errno::EAGAIN.new.message)}/).to_stderr
    expect(File.exist?(pid_path)).to be(true)
  end

  it 'keeps the PID file when the socket cannot be removed' do
    UNIXServer.new(socket_path).close
    allow(File).to receive(:delete).and_call_original
    allow(File).to receive(:delete).with(socket_path).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
    expect(File.exist?(pid_path)).to be(true)
  rescue NotImplementedError, Errno::EAFNOSUPPORT, Errno::EPERM => e
    skip "AF_UNIX sockets are unavailable (#{e.class})"
  end

  it 'retries disabled-user cleanup after a config removal failure' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    expect(Process).not_to receive(:kill)
    allow(File).to receive(:delete).and_call_original
    allow(File).to receive(:delete).with(config_path).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Error trying to clean up disabled user gone: Permission denied/).to_stderr
      .and output("gone (disabled)\n").to_stdout
    expect(File.exist?(pid_path)).to be(true)
    expect(File.exist?(secret_path)).to be(false)

    allow(File).to receive(:delete).with(config_path).and_call_original
    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
    expect([run_dir, config_path].any? { |path| File.exist?(path) }).to be(false)
  end
  it 'discovers unfinished disabled-user cleanup after nginx removes its PID' do
    user = 'ood-test-no-such-account'
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_call_original
    allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
    allow(NginxStage).to receive(:pun_pid_path).with(user: '*')
      .and_return(File.join(dir, '*', '*-passenger.pid'))
    actual_run_dir = File.join(dir, user)
    File.rename(run_dir, actual_run_dir)
    actual_pid = File.join(actual_run_dir, "#{user}-passenger.pid")
    File.rename(File.join(actual_run_dir, 'passenger.pid'), actual_pid)
    allow(NginxStage).to receive(:pun_pid_path).with(user: user).and_return(actual_pid)
    actual_config = File.join(dir, "#{user}.conf")
    File.rename(config_path, actual_config)
    allow(NginxStage).to receive(:pun_config_path).with(user: '*').and_return(File.join(dir, '*.conf'))
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(actual_config)

    stub_live_pid(title: "nginx: master process (spec) -c #{actual_config}")
    expect(Process).to receive(:kill).with('TERM', 4242) { File.delete(actual_pid) }
    allow(File).to receive(:delete).and_call_original
    allow(File).to receive(:delete).with(actual_config).and_raise(Errno::EACCES)

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
      .and output("#{user} (disabled)\n").to_stdout
    expect(File).to exist("#{actual_config}.cleanup")

    allow(File).to receive(:delete).with(actual_config).and_call_original
    expect { generator.invoke }.to output('').to_stderr.and output("#{user} (disabled)\n").to_stdout
    expect(File).not_to exist(actual_config)
    expect(File).not_to exist("#{actual_config}.cleanup")
  end

  it 'clears the pending marker when only unrelated files remain in the run directory' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    expect(Process).not_to receive(:kill)
    unrelated_file = File.join(run_dir, 'unrelated')
    File.write(unrelated_file, '')
    allow(generator).to receive(:sleep).with(0.5)

    expect { generator.invoke }.to output(/Directory not empty/).to_stderr.and output("gone (disabled)\n").to_stdout
    expect(File).to exist(unrelated_file)
    expect(File).not_to exist("#{config_path}.cleanup")
  end

  it 'retains a retry marker after a transient run directory removal failure' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    allow(Dir).to receive(:rmdir).and_call_original
    expect(Dir).to receive(:rmdir).with(run_dir).ordered.and_raise(Errno::EACCES)
    expect(Dir).to receive(:rmdir).with(run_dir).ordered.and_call_original

    expect { generator.invoke }.to output(/Permission denied/).to_stderr
      .and output("gone (disabled)\n").to_stdout
    expect(File).not_to exist(pid_path)
    expect(File).to exist("#{config_path}.cleanup")
    expect { generator.invoke }.to output('').to_stderr.and output("gone (disabled)\n").to_stdout
    expect(File).not_to exist(run_dir)
    expect(File).not_to exist("#{config_path}.cleanup")
  end

  it 'leaves a restored account alone once it obtains the startup lock' do
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    expect(NginxStage).to receive(:with_pun_start_lock).with(user: 'gone') do |&cleanup|
      allow(NginxStage::User).to receive(:new).with('gone').and_return(double('restored account'))
      cleanup.call
    end
    stub_live_pid
    allow(Process).to receive(:kill)
    allow(generator).to receive(:force).and_return(false)
    allow(generator).to receive(:session_count).and_return(1)

    expect { generator.invoke }.not_to output.to_stdout

    expect(Process).not_to have_received(:kill)
    expect(File).to exist(config_path)
    expect(File).to exist(secret_path)
  end

end
