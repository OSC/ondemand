# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe 'PUN lifecycle' do
  let(:test_user) { 'spec' }
  let(:pid) { 123 }
  let(:dir) { Dir.mktmpdir }
  let(:run_dir) { File.join(dir, 'run') }
  let(:pid_path) { File.join(run_dir, 'passenger.pid') }
  let(:socket_path) { File.join(run_dir, 'passenger.sock') }
  let(:config_path) { File.join(dir, 'spec.conf') }
  let(:ok) { instance_double(Process::Status, success?: true) }
  let(:failed) { instance_double(Process::Status, success?: false) }

  # Linux stat fields after comm: state is field 3, starttime is field 22.
  def proc_stat(pid, state: 'S', start_time: '12345', comm: 'nginx')
    "#{pid} (#{comm}) #{([state] + Array.new(18, '0') + [start_time]).join(' ')}"
  end

  def stub_master(pid)
    allow(Process).to receive(:getpgid).with(pid).and_return(pid)
    allow(File).to receive(:read).with("/proc/#{pid}/stat").and_return(proc_stat(pid))
    allow(File).to receive(:read).with("/proc/#{pid}/cmdline")
      .and_return("nginx: master process (spec) -c #{config_path}\0")
    allow(File).to receive(:identical?).with("/proc/#{pid}/exe", NginxStage.nginx_bin).and_return(true)
  end

  def stub_exit(pid)
    allow(File).to receive(:read).with("/proc/#{pid}/stat").and_raise(Errno::ENOENT)
  end

  before do
    passwd = Struct.new(:name, :uid, :gid, :shell).new(test_user, 1000, 1000, '/bin/bash')
    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(Struct.new(:name).new(test_user))
    allow(NginxStage).to receive(:pun_pid_path).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).and_return(config_path)
    allow(NginxStage).to receive(:clean_nginx_env)
    allow(Process).to receive(:getpgid).and_call_original
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:identical?).and_call_original
    FileUtils.mkdir_p(run_dir)
    File.write(pid_path, pid.to_s)
    stub_master(pid)
  end

  after { FileUtils.remove_entry(dir) }

  describe 'shutdown' do
    let(:generator) { NginxStage::NginxProcessGenerator.new(user: test_user, signal: 'stop') }

    it 'waits for the old master to remove its PID file and socket after stop' do
      allow(Open3).to receive(:capture2e).and_return(['', ok])
      allow(generator).to receive(:sleep) do
        File.delete(pid_path)
        stub_exit(123)
      end

      generator.send(:run_nginx, test_user, signal: :stop)

      expect(generator).to have_received(:sleep).once
    end

    it 'does not wait after a failed stop or a non-shutdown signal' do
      allow(Open3).to receive(:capture2e).and_return(['', failed], ['', ok])
      expect(generator).not_to receive(:wait_for_pun_exit)

      generator.send(:run_nginx, test_user, signal: :stop)
      generator.send(:run_nginx, test_user, signal: :reload)
    end

    it 'times out while a dangling socket symlink remains' do
      stub_const('NginxStage::Generator::PUN_SHUTDOWN_TIMEOUT', 0)
      File.symlink(File.join(dir, 'missing'), socket_path)
      allow(generator).to receive(:sleep)

      expect { generator.send(:wait_for_pun_exit, test_user) }
        .to raise_error(NginxStage::Error, 'timed out waiting for the PUN of spec to shut down')
    end

    it 'waits for the original process even after both paths have disappeared' do
      File.delete(pid_path)
      process = NginxStage::PunProcess.new(123, config_path)
      allow(generator).to receive(:sleep) { stub_exit(123) }

      generator.send(:wait_for_pun_exit, test_user, process: process)

      expect(generator).to have_received(:sleep).once
    end

    it 'refuses to invoke nginx with an unrelated PID' do
      allow(File).to receive(:read).with('/proc/123/cmdline').and_return('/usr/bin/sleep\0')
      expect(Open3).not_to receive(:capture2e)

      expect { generator.send(:run_nginx, test_user, signal: :stop) }
        .to raise_error(NginxStage::Error, /refusing to signal unverified PUN/)
    end

    it 'waits through quit unlinking the socket, then the PID file, then process exit' do
      File.write(socket_path, '')
      allow(Open3).to receive(:capture2e) do
        File.delete(socket_path)
        ['', ok]
      end
      polls = 0
      allow(generator).to receive(:sleep) do
        polls += 1
        polls == 1 ? File.delete(pid_path) : stub_exit(123)
      end

      generator.send(:run_nginx, test_user, signal: :quit)

      expect(polls).to eq(2)
    end
  end

  describe 'app restart' do
    let(:generator) { NginxStage::AppConfigGenerator.new(user: test_user, sub_request: '/sys/dashboard') }
    let(:restart) { generator.class.hooks.fetch(:exec_nginx) }

    it 'starts the replacement only after the old PUN has exited' do
      calls = []
      allow(Open3).to receive(:capture2e) do |*args|
        calls << args.last(2)
        ['', ok]
      end
      allow(generator).to receive(:wait_for_pun_exit) { calls << :waited }

      expect { generator.instance_eval(&restart) }.to raise_error(SystemExit) { |e| expect(e).to be_success }
      expect(calls).to eq([['-s', 'stop'], :waited, ['-c', config_path]])
    end

    it 'does not start a replacement when the old PUN does not exit' do
      allow(Open3).to receive(:capture2e).and_return(['', ok])
      allow(generator).to receive(:wait_for_pun_exit).and_raise(NginxStage::Error, 'timed out')

      expect { generator.instance_eval(&restart) }.to raise_error(NginxStage::Error, 'timed out')
      expect(Open3).to have_received(:capture2e).once
    end
  end

  describe 'PUN lock' do
    it 'is taken by startup, app restart and nginx signals' do
      [
        NginxStage::PunConfigGenerator.new(user: test_user),
        NginxStage::AppConfigGenerator.new(user: test_user, sub_request: '/sys/dashboard'),
        NginxStage::NginxProcessGenerator.new(user: test_user, signal: 'stop')
      ].each do |generator|
        expect(generator).to receive(:with_pun_lock).with(generator.user)
        generator.invoke
      end
    end

    it 'makes cleanup skip a busy user instead of waiting' do
      generator = NginxStage::NginxCleanGenerator.new
      File.open("#{config_path}.lock", File::RDWR | File::CREAT) do |held|
        held.flock(File::LOCK_EX)

        expect { generator.send(:with_pun_lock, test_user, nonblock: true) { raise 'ran while locked' } }
          .to raise_error(NginxStage::Error, 'another nginx_stage command is running for spec')
      end
    end

    it 'prints a skipped nginx command without creating a lock file' do
      generator = NginxStage::NginxProcessGenerator.new(user: test_user, skip_nginx: true)
      expect(generator).not_to receive(:with_pun_lock)

      expect { generator.invoke }.to output(/-c #{Regexp.escape(config_path)}/).to_stdout
      expect(File.exist?("#{config_path}.lock")).to be(false)
    end
  end

  describe 'startup guard' do
    let(:generator) { NginxStage::PunConfigGenerator.new(user: test_user) }
    let(:pid) { Process.pid }
    let(:cmdline) { "/proc/#{pid}/cmdline" }

    it 'treats a master draining after quit (socket already gone) as running' do
      expect(generator.send(:pun_running?)).to be(true)
    end

    it 'ignores an unrelated process using the PID once the socket is gone' do
      allow(File).to receive(:read).with(cmdline).and_return('/usr/bin/vim')

      expect(generator.send(:pun_running?)).to be(false)
    end

    it 'does not mistake tailing the config file for an nginx master' do
      allow(File).to receive(:read).with(cmdline).and_return("/usr/bin/tail\0-f\0#{config_path}\0")

      expect(generator.send(:pun_running?)).to be(false)
    end

    it 'does not match a different config whose name starts with this config' do
      allow(File).to receive(:read).with(cmdline).and_return("nginx: master process (spec) -c #{config_path}.backup")

      expect(generator.send(:pun_running?)).to be(false)
    end

    it 'blocks startup when a plausible master has an unverified executable' do
      allow(File).to receive(:identical?).with("/proc/#{Process.pid}/exe", NginxStage.nginx_bin).and_return(false)

      expect { generator.send(:pun_running?) }.to raise_error(NginxStage::Error, /startup blocked by unverified PUN/)
    end
  end

  describe 'disabled-user cleanup' do
    let(:pid) { 4242 }
    let(:secret_path) { File.join(dir, 'spec.secret_key_base.txt') }
    let(:generator) { NginxStage::NginxCleanGenerator.new }

    before do
      allow(NginxStage).to receive(:active_users).and_return([])
      allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
      allow(NginxStage).to receive(:pun_secret_key_base_path).and_return(secret_path)
      File.write(config_path, '')
      File.write(secret_path, '')
    end

    [false, true].each do |exit_race|
      it "cleans up after TERM delivery#{' races with master exit' if exit_race}" do
        expect(Process).to receive(:kill).with('TERM', 4242) do
          File.delete(pid_path)
          stub_exit(4242)
          raise Errno::ESRCH if exit_race
        end

        expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
        expect([config_path, secret_path, run_dir].none? { |path| File.exist?(path) }).to be(true)
      end
    end

    it 'does not signal a PID reused between inspection and verification' do
      allow(File).to receive(:read).with('/proc/4242/stat')
        .and_return(proc_stat(4242), proc_stat(4242, start_time: '99999'))
      expect(Process).not_to receive(:kill)

      expect { generator.invoke }.to output(/refusing to signal unverified PUN/).to_stderr
        .and output("gone (disabled)\n").to_stdout
      expect([pid_path, config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
    end

    it 'refuses to terminate an unrelated process or remove its state' do
      allow(File).to receive(:read).with('/proc/4242/cmdline').and_return('/usr/bin/sleep\0')
      expect(Process).not_to receive(:kill)

      expect { generator.invoke }.to output(/refusing to signal unverified PUN/).to_stderr
        .and output("gone (disabled)\n").to_stdout
      expect([pid_path, config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
    end

    it 'preserves config and secret when shutdown times out' do
      stub_const('NginxStage::Generator::PUN_SHUTDOWN_TIMEOUT', 0)
      allow(Process).to receive(:kill).with('TERM', 4242).and_return(1)

      expect { generator.invoke }.to output(/timed out/).to_stderr.and output("gone (disabled)\n").to_stdout
      expect([config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
    end
  end

  describe NginxStage::PunProcess do
    it 'parses start time when the process name contains spaces and parentheses' do
      allow(File).to receive(:read).with('/proc/123/stat').and_return(proc_stat(123, comm: 'a ) b (c)'))
      process = described_class.new(123, config_path)

      expect(process.running?).to be(true)
    end

    it 'rejects a reused PID during inspection' do
      process = described_class.new(123, config_path)
      allow(File).to receive(:read).with('/proc/123/stat').and_return(proc_stat(123, start_time: '99999'))
      expect(Process).not_to receive(:kill)

      expect(process.running?).to be(false)
      expect(process.master?).to be(false)
    end

    it 'treats an exited process or zombie as stopped' do
      process = described_class.new(123, config_path)
      allow(File).to receive(:read).with('/proc/123/stat').and_return(proc_stat(123, state: 'Z'))
      expect(process.running?).to be(false)

      stub_exit(123)
      expect(process.running?).to be(false)
    end

    it 'rejects a changed executable during inspection' do
      process = described_class.new(123, config_path)
      expect(process.master?).to be(true)
      allow(File).to receive(:identical?).with('/proc/123/exe', NginxStage.nginx_bin).and_return(false)
      expect(Process).not_to receive(:kill)

      expect(process.master?).to be(false)
    end

    it 'does not mistake unreadable process state for process exit' do
      process = described_class.new(123, config_path)
      allow(File).to receive(:read).with('/proc/123/stat').and_raise(Errno::EACCES)

      expect { process.running? }.to raise_error(Errno::EACCES)
    end
  end
end
