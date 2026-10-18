# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::Generator do
  let(:test_user) { 'spec' }
  let(:generator) { described_class.new }
  let(:socket_path) { '/var/run/ondemand-nginx/spec/passenger.sock' }

  before do
    allow(NginxStage).to receive(:pun_socket_path)
      .with(user: test_user).and_return(socket_path)
  end

  describe '#wait_for_pun_socket_shutdown' do
    it 'waits for an ordinary socket path to disappear' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(true, false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(false)

      expect(generator).to receive(:sleep)
        .with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once

      generator.send(:wait_for_pun_socket_shutdown, user: test_user)
    end

    it 'also waits for a dangling symlink at the socket path' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC).and_return(0.0, 0.1)
      allow(File).to receive(:exist?).with(socket_path).and_return(false)
      allow(File).to receive(:symlink?).with(socket_path).and_return(true, false)

      expect(generator).to receive(:sleep)
        .with(described_class::PUN_SOCKET_SHUTDOWN_POLL_INTERVAL).once

      generator.send(:wait_for_pun_socket_shutdown, user: test_user)
    end

    it 'fails instead of starting over a socket that never disappears' do
      allow(Process).to receive(:clock_gettime)
        .with(Process::CLOCK_MONOTONIC)
        .and_return(0.0, described_class::PUN_SOCKET_SHUTDOWN_TIMEOUT)
      allow(File).to receive(:exist?).with(socket_path).and_return(true)

      expect { generator.send(:wait_for_pun_socket_shutdown, user: test_user) }
        .to raise_error(
          NginxStage::Error,
          "timed out waiting for PUN socket shutdown: #{socket_path}"
        )
    end
  end
end
