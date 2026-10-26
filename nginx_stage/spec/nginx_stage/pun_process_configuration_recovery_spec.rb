# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::PunProcess do
  let(:directory) { Dir.mktmpdir('pun-config-recovery') }
  let(:process_root) { File.join(directory, 'process') }
  let(:binary) { File.join(directory, 'nginx') }
  let(:other_binary) { File.join(directory, 'replacement-nginx') }
  let(:saved_config) { File.join(directory, 'before-migration.yml') }
  let(:settings) do
    {
      'nginx_bin'       => binary,
      'pun_config_path' => File.join(directory, 'puns', '%<user>s.conf'),
      'pun_pid_path'    => File.join(directory, 'pun.pid'),
      'pun_socket_path' => File.join(directory, 'pun.sock')
    }
  end
  let(:process) { described_class.new(pid: 12_345, user: 'spec') }
  let(:handle) { File.open(process_root, File::RDONLY) }
  let(:generator) { NginxStage::Generator.new }

  around do |example|
    original = settings.keys.to_h { |key| [key, NginxStage.instance_variable_get("@#{key}")] }
    example.run
  ensure
    original.each { |key, value| NginxStage.public_send("#{key}=", value) }
  end

  before do
    FileUtils.mkdir_p(process_root)
    [binary, other_binary].each do |path|
      File.write(path, 'isolated executable fixture')
      File.chmod(0o755, path)
    end
    File.write(saved_config, YAML.dump(settings))
    File.chmod(0o600, saved_config)
    NginxStage.read_configuration(saved_config)
    File.write(settings.fetch('pun_pid_path'), '12345')
    File.write(settings.fetch('pun_socket_path'), 'occupied runtime entry')
    File.symlink(binary, File.join(process_root, 'exe'))
    File.write(File.join(process_root, 'cmdline'),
               "nginx: master process (spec) #{NginxStage.nginx_args(user: 'spec').join(' ')}\0")
    File.write(File.join(process_root, 'stat'), "12345 (nginx) S #{'0 ' * 25}")
    File.write(File.join(process_root, 'status'), "Uid:\t#{Process.euid}\t#{Process.euid}\t0\t0\n")
    handle
    allow(described_class).to receive(:proc_available?).and_return(true)
    allow(Process).to receive(:getpgid).with(12_345).and_return(12_345)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with('/proc/12345', File::RDONLY).and_yield(handle)
    allow(NginxStage).to receive_messages(active_users: ['spec'], inactive_users: [], pending_cleanup_users: [])
  end

  after do
    handle.close
    FileUtils.remove_entry(directory)
  end

  def restore_saved_configuration
    with_modified_env('NGINX_STAGE_CONFIG_FILE' => saved_config) do
      NginxStage.read_configuration(NginxStage.config_file)
    end
  end

  ['pun_config_path', 'nginx_bin', 'both'].each do |changed|
    it "preserves a PUN after changing #{changed}, then verifies shutdown using the saved configuration" do
      NginxStage.nginx_bin = other_binary unless changed == 'pun_config_path'
      NginxStage.pun_config_path = File.join(directory, 'moved', '%<user>s.conf') unless changed == 'nginx_bin'
      expect(Process).not_to receive(:kill)
      expect(Open3).not_to receive(:capture2e)
      allow(Kernel).to receive(:syscall).and_raise('unexpected signal before configuration recovery')

      expect { generator.send(:pun_running?, user: 'spec') }.to raise_error(NginxStage::Error, /identity is uncertain/)
      expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is unknown/)
      expect { NginxStage::NginxCleanGenerator.new(force: true).invoke }
        .to output(/identity is uncertain/).to_stderr
      expect(File.read(settings.fetch('pun_pid_path'))).to eq('12345')
      expect(File.read(settings.fetch('pun_socket_path'))).to eq('occupied runtime entry')

      restore_saved_configuration
      expect(process.state).to eq(:matching)
      expect(Kernel).to receive(:syscall)
        .with(described_class::SIGNAL_SYSCALL, handle.fileno, Signal.list.fetch('TERM'), 0, 0) do
          File.unlink(settings.fetch('pun_socket_path'))
          File.unlink(settings.fetch('pun_pid_path'))
        end
      expect(generator.send(:run_nginx, user: 'spec', signal: :stop).last).to be_success
    end
  end

  it 'continues refusing a different process after restoring the saved configuration' do
    NginxStage.nginx_bin = other_binary
    File.write(File.join(process_root, 'cmdline'), 'nginx: master process (other) -c /unrelated.conf')
    restore_saved_configuration
    expect(Kernel).not_to receive(:syscall)
    expect(Process).not_to receive(:kill)

    expect { process.signal(:stop) }.to raise_error(NginxStage::Error, /identity is unknown/)
    expect(File.read(settings.fetch('pun_pid_path'))).to eq('12345')
  end
end
