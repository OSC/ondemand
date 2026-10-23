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
end
