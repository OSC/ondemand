# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::NginxShowGenerator do
  let(:directory) { Dir.mktmpdir('nginx-show-') }
  let(:user) { 'spec' }
  let(:pid_path) { File.join(directory, 'pun.pid') }
  let(:socket_path) { File.join(directory, 'pun.sock') }
  let(:generator) { described_class.new(user: user) }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(Struct.new(:name).new(user))
    allow(NginxStage).to receive_messages(pun_pid_path: pid_path, pun_socket_path: socket_path)
    File.write(pid_path, '12345')
    File.write(socket_path, 'socket fixture')
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    allow(File).to receive(:socket?).and_call_original
    allow(File).to receive(:socket?).with(socket_path).and_return(true)
  end

  after { FileUtils.remove_entry(directory) }

  it 'shows zero sessions for a valid account with no selected processes' do
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(FileUtils).not_to receive(:rm)
    status = instance_double(Process::Status, success?: false, exitstatus: 1)
    allow(Open3).to receive(:capture3).and_return(["CMD\n", '', status])
    expect { generator.invoke }.to output(/Sessions: 0/).to_stdout
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(socket_path)).to eq('socket fixture')
  end

  it 'reports a genuine process-list failure rather than claiming zero sessions' do
    expect(NginxStage::PunProcess).not_to receive(:signal)
    expect(FileUtils).not_to receive(:rm)
    status = instance_double(Process::Status, success?: false, exitstatus: 1)
    allow(Open3).to receive(:capture3).and_return(["CMD\n", 'ps: failed to read procfs', status])
    allow(generator).to receive(:puts)
    expect { generator.invoke }.to raise_error(NginxStage::Error, /ps failed/)
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(socket_path)).to eq('socket fixture')
  end
end
