# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::NginxCleanGenerator do
  let(:user) { 'spec' }
  let(:generator) { described_class.new }
  let(:directory) { Dir.mktmpdir('nginx-clean-invalid-pid') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:config_path) { File.join(directory, 'pun.conf') }

  before do
    File.write(pid_path, 'invalid PID')
    allow(NginxStage).to receive_messages(active_users: [user], inactive_users: [])
    allow(NginxStage).to receive(:pun_pid_path).with(user: user).and_return(pid_path)
    allow(NginxStage).to receive(:pun_socket_path).with(user: user).and_return(socket_path)
    allow(NginxStage).to receive(:pun_config_path).with(user: user).and_return(config_path)
  end

  after do
    allow(File).to receive(:unlink).and_call_original
    FileUtils.remove_entry(directory)
  end

  it 'reports successful removal only after deleting the invalid PID under the lock' do
    expect(Open3).not_to receive(:capture2e)
    allow(FileUtils).to receive(:rm).and_wrap_original do |original, *args, **options|
      File.open("#{config_path}.lock", File::RDWR) do |competitor|
        expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to be(false)
      end
      original.call(*args, **options)
    end

    expect { generator.invoke }.to output(/Removed invalid PID file/).to_stderr
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'reports denied deletion without claiming that the invalid PID was removed' do
    expect(Open3).not_to receive(:capture2e)
    allow(File).to receive(:unlink).and_call_original
    allow(File).to receive(:unlink).with(pid_path).and_raise(Errno::EACCES)

    expect { generator.invoke }
      .to output(/\AError trying to clean up active user spec: Permission denied.*\n\z/).to_stderr
    expect(File.read(pid_path)).to eq('invalid PID')
  end

  it 'does not claim removal if the PID file has already disappeared' do
    expect(Open3).not_to receive(:capture2e)
    allow(NginxStage::PidFile).to receive(:new).with(pid_path).and_wrap_original do |original, path|
      original.call(path)
    rescue NginxStage::InvalidPidFile
      File.unlink(path)
      raise
    end

    expect { generator.invoke }.not_to output.to_stderr
    expect(File.exist?(pid_path)).to be(false)
  end

  it 'preserves the invalid PID when the socket path is a dangling symlink' do
    expect(Open3).not_to receive(:capture2e)
    File.symlink(File.join(directory, 'missing-target'), socket_path)

    expect { generator.invoke }.to output(/socket path still exists/).to_stderr
    expect(File.read(pid_path)).to eq('invalid PID')
    expect(File.symlink?(socket_path)).to be(true)
  end

  it 'leaves invalid PID state untouched with --skip-nginx' do
    expect(Open3).not_to receive(:capture2e)
    generator = described_class.new(skip_nginx: true)

    expect { generator.invoke }.to output(/Skipping cleanup/).to_stderr
    expect(File.read(pid_path)).to eq('invalid PID')
  end
end
