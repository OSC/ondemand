# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

# Other cleanup specs always report zero sessions. This covers the rule
# nginx_clean exists for: busy PUNs stay up unless --force is given.
describe NginxStage::NginxCleanGenerator do
  let(:user) { 'spec' }
  let(:directory) { Dir.mktmpdir('clean-sessions') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'spec.conf') }

  before do
    File.write(pid_path, "12345\n")
    File.write(config_path, 'configuration')
    # Session policy does not need an actual listener; native probe specs cover it.
    File.write(socket_path, 'socket fixture')
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(socket_path).and_return(true)
    allow(NginxStage).to receive_messages(active_users: [user], inactive_users: [], pending_cleanup_users: [])
    allow(NginxStage).to receive(:pun_pid_path).with(user: user).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).with(user: user).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
    allow(NginxStage::PunProcess).to receive(:state).and_return(:matching)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  [1, 3].each do |sessions|
    it "leaves a live PUN with #{sessions} active session(s) running without --force" do
      generator = described_class.new
      allow(generator).to receive(:session_count).with(user).and_return(sessions)
      expect(NginxStage::PunProcess).not_to receive(:signal)

      expect { generator.invoke }.to output('').to_stdout.and output('').to_stderr
      expect(File.read(pid_path)).to eq("12345\n")
      expect(File.socket?(socket_path)).to be(true)
      expect(File.read(config_path)).to eq('configuration')
    end
  end

  it 'stops a live PUN with active sessions when --force is given' do
    generator = described_class.new(force: true)
    allow(generator).to receive(:session_count).with(user).and_return(2)
    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 12_345), user: user, signal: :stop) do
      File.unlink(pid_path)
      File.unlink(socket_path)
    end

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
    expect(File.exist?(pid_path)).to be(false)
    expect(File.read(config_path)).to eq('configuration')
  end

  it 'only lists a busy PUN with --force --skip-nginx' do
    generator = described_class.new(force: true, skip_nginx: true)
    allow(generator).to receive(:session_count).with(user).and_return(2)
    expect(NginxStage::PunProcess).not_to receive(:signal)

    expect { generator.invoke }.to output("spec\n").to_stdout
    expect(File.read(pid_path)).to eq("12345\n")
    expect(File.socket?(socket_path)).to be(true)
  end

  [
    [124, ''],
    [1, ''],
    [1, "CMD\nPassenger RubyApp: /partial\n"]
  ].each do |exitstatus, output|
    it "preserves a live PUN when session detection fails with #{exitstatus} and #{output.inspect}" do
      generator = described_class.new
      status = instance_double(Process::Status, success?: false, exitstatus: exitstatus)
      expect(Open3).to receive(:capture2).with('timeout', '10', 'ps', '-o', 'cmd', '-u', user)
                                         .and_return([output, status])
      expect(NginxStage::PunProcess).not_to receive(:signal)
      expect { generator.invoke }.to output(/Unable to determine PUN sessions/).to_stderr
      expect(File.read(pid_path)).to eq("12345\n")
      expect(File.exist?(socket_path)).to be(true)
      expect(File.read(config_path)).to eq('configuration')
    end
  end

  it 'continues to a subsequent candidate after a session command failure' do
    generator = described_class.new
    other_user = 'next-user'
    other_pid = File.join(directory, 'next.pid')
    other_socket = File.join(directory, 'next.sock')
    File.write(other_pid, "67890\n")
    File.write(other_socket, 'socket fixture')
    allow(NginxStage).to receive(:active_users).and_return([user, other_user])
    allow(NginxStage).to receive(:pun_pid_path).with(user: other_user).and_return(other_pid)
    allow(NginxStage).to receive(:pun_socket_path).with(user: other_user).and_return(other_socket)
    allow(NginxStage).to receive(:pun_config_path).with(user: other_user).and_return(File.join(directory, 'next.conf'))
    allow(File).to receive(:socket?).with(other_socket).and_return(true)
    failure = instance_double(Process::Status, success?: false, exitstatus: 124)
    success = instance_double(Process::Status, success?: true)
    expect(Open3).to receive(:capture2).ordered.and_return(['', failure])
    expect(Open3).to receive(:capture2).ordered.and_return(["CMD\n", success])
    expect(NginxStage::PunProcess).to receive(:signal)
      .with(pid_file: have_attributes(pid: 67_890), user: other_user, signal: :stop) do
      File.unlink(other_pid)
      File.unlink(other_socket)
    end
    expect { generator.invoke }.to output(/Unable to determine PUN sessions/).to_stderr
    expect(File.exist?(other_pid)).to be(false)
    expect(File.read(pid_path)).to eq("12345\n")
    expect(File.exist?(socket_path)).to be(true)
  end

  it 'bypasses session detection only when explicitly forced' do
    generator = described_class.new(force: true)
    expect(Open3).not_to receive(:capture2)
    expect(NginxStage::PunProcess).to receive(:signal) do
      File.unlink(pid_path)
      File.unlink(socket_path)
    end
    generator.invoke
  end
end
