# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::Generator do
  let(:test_user) { 'spec' }
  let(:directory) { Dir.mktmpdir('pun-startup-socket-spec') }
  let(:config_path) { File.join(directory, 'spec.conf') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:secret_path) { File.join(directory, 'spec.secret') }
  let(:target_path) { File.join(directory, 'socket-target') }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell)
                   .new(1000, test_user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, test_user)
    allow(Etc).to receive(:getpwnam).with(test_user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
    allow(NginxStage).to receive_messages(
      pun_config_path: config_path, pun_pid_path: pid_path,
      pun_socket_path: socket_path, pun_secret_key_base_path: secret_path
    )
    allow(Process).to receive(:getpgid).with(12_345).and_raise(Errno::ESRCH)
    File.write(pid_path, '12345')
    File.write(config_path, 'original configuration')
    File.write(secret_path, 'original secret')
  end

  after do
    FileUtils.remove_entry(directory)
  end

  [:pun, :direct].each do |entry_point|
    context "with #{entry_point} startup and a dead recorded PID" do
      let(:startup) do
        if entry_point == :pun
          NginxStage::PunConfigGenerator.new(user: test_user)
        else
          NginxStage::NginxProcessGenerator.new(user: test_user)
        end
      end

      [:file, :symlink, :dangling_symlink].each do |entry|
        it "blocks an occupied #{entry} socket path before setup or nginx execution" do
          if entry == :file
            # Startup tests occupancy only: listening, stale and uncertain
            # sockets must all be preserved without attempting a probe.
            File.write(socket_path, 'occupied socket path')
          else
            File.write(target_path, 'socket target') if entry == :symlink
            File.symlink(target_path, socket_path)
          end
          original_socket = File.lstat(socket_path)
          expect(startup).not_to receive(:empty_directory)
          expect(startup).not_to receive(:template)
          expect(NginxStage).not_to receive(:clean_nginx_env)
          expect(NginxStage::SocketProbe).not_to receive(:new)
          expect(Open3).not_to receive(:capture2e)

          expect { startup.invoke }
            .to raise_error(NginxStage::Error, /PID is dead.*socket path is occupied.*nginx_clean --user=spec/)

          expect(File.read(pid_path)).to eq('12345')
          expect(File.read(config_path)).to eq('original configuration')
          expect(File.read(secret_path)).to eq('original secret')
          expect(File.lstat(socket_path).ino).to eq(original_socket.ino)
          if entry == :file
            expect(File.read(socket_path)).to eq('occupied socket path')
          else
            expect(File.readlink(socket_path)).to eq(target_path)
            expect(File.read(target_path)).to eq('socket target') if entry == :symlink
          end
          File.open("#{config_path}.lock", File::RDWR) do |competitor|
            expect(competitor.flock(File::LOCK_EX | File::LOCK_NB)).to eq(0)
          end
        end
      end
    end
  end

  it 'still permits configuration-only generation with an occupied socket path' do
    File.write(socket_path, 'occupied socket path')
    startup = NginxStage::PunConfigGenerator.new(user: test_user, skip_nginx: true)
    allow(NginxStage::PunConfigGenerator).to receive(:hooks).and_return(
      skip_running_pun: NginxStage::PunConfigGenerator.hooks.fetch(:skip_running_pun),
      create_config:    proc { File.write(config_path, 'generated configuration') }
    )
    expect(NginxStage::SocketProbe).not_to receive(:new)
    expect(Open3).not_to receive(:capture2e)

    startup.invoke

    expect(File.read(config_path)).to eq('generated configuration')
    expect(File.read(pid_path)).to eq('12345')
    expect(File.read(socket_path)).to eq('occupied socket path')
    expect(File.read(secret_path)).to eq('original secret')
  end
end
