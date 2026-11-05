# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe 'nginx_clean selection and dry runs' do
  let(:dir) { Dir.mktmpdir }
  let(:pid_path) { File.join(dir, 'passenger.pid') }
  let(:socket_path) { File.join(dir, 'passenger.sock') }
  let(:config_path) { File.join(dir, 'spec.conf') }
  let(:secret_path) { File.join(dir, 'spec.secret') }

  before do
    [pid_path, socket_path, config_path, secret_path].each { |path| File.write(path, '4242') }
    allow(NginxStage).to receive(:pun_pid_path).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).and_return(config_path)
    allow(NginxStage).to receive(:pun_secret_key_base_path).and_return(secret_path)
    allow(NginxStage).to receive(:active_users).and_return([])
    allow(NginxStage).to receive(:inactive_users).and_return([])
    expect(Process).not_to receive(:kill)
    expect(Open3).not_to receive(:capture2e)
  end

  after { FileUtils.remove_entry(dir) }

  it 'only reports disabled users with --skip-nginx' do
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    generator = NginxStage::NginxCleanGenerator.new(skip_nginx: true)
    expect(generator).not_to receive('`')

    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
    expect([pid_path, socket_path, config_path, secret_path].all? { |path| File.exist?(path) }).to be(true)
  end

  it 'does not act on disabled users excluded by --user' do
    allow(NginxStage).to receive(:inactive_users).and_return(['gone'])
    generator = NginxStage::NginxCleanGenerator.new(user: 'other')
    expect(generator).not_to receive('`')

    expect { generator.invoke }.to output('').to_stdout.and output('').to_stderr
    expect(File.exist?(config_path)).to be(true)
  end

  it 'reports only the selected disabled user during a dry run' do
    allow(NginxStage).to receive(:inactive_users).and_return(['gone', 'other'])
    generator = NginxStage::NginxCleanGenerator.new(user: 'gone', skip_nginx: true)
    expect(generator).not_to receive('`')

    expect { generator.invoke }.to output("gone (disabled)\n").to_stdout.and output('').to_stderr
  end

  it 'does not remove stale active-user files during a dry run' do
    allow(NginxStage).to receive(:active_users).and_return(['spec'])
    allow(Process).to receive(:getpgid).with(4242).and_raise(Errno::ESRCH)
    socket = instance_double(NginxStage::SocketFile)
    allow(NginxStage::SocketFile).to receive(:new).and_return(socket)
    expect(socket).not_to receive(:delete)
    generator = NginxStage::NginxCleanGenerator.new(skip_nginx: true)
    allow(generator).to receive(:session_count).and_return(0)

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
    expect([pid_path, socket_path].all? { |path| File.exist?(path) }).to be(true)
  end

  it 'does not report active users excluded by --user' do
    allow(NginxStage).to receive(:active_users).and_return(['spec'])
    generator = NginxStage::NginxCleanGenerator.new(user: 'other', skip_nginx: true)
    expect(generator).not_to receive(:session_count)

    expect { generator.invoke }.to output('').to_stdout.and output('').to_stderr
  end
end
