# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require_relative '../support/pun_native_environment'

RSpec.describe PunNativeEnvironment do
  include described_class

  it 'uses the production capability probe for native signaling tests' do
    expect(NginxStage::PunProcess).to receive(:check_signal_support!).once.and_return(true)
    expect(Kernel).not_to receive(:syscall)

    with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => '1') do
      require_native_signaling!
    end
  end

  context 'when native signaling is unavailable' do
    before do
      allow(NginxStage::PunProcess).to receive(:check_signal_support!)
        .and_raise(NginxStage::Error, 'caller PID namespace unavailable')
    end

    it 'skips optional coverage with the production diagnosis' do
      with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => nil) do
        expect(self).to receive(:skip)
          .with('descriptor signaling unavailable: caller PID namespace unavailable').once

        require_native_signaling!
      end
    end

    it 'fails required coverage instead of skipping it' do
      with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => '1') do
        expect(self).not_to receive(:skip)
        expect { require_native_signaling! }
          .to raise_error(RuntimeError, /Required native coverage unavailable: .*caller PID namespace unavailable/)
      end
    end
  end

  it 'propagates unexpected probe errors instead of hiding them as capability skips' do
    allow(NginxStage::PunProcess).to receive(:check_signal_support!).and_raise(RuntimeError, 'unexpected probe bug')
    expect(self).not_to receive(:skip)

    expect { require_native_signaling! }.to raise_error(RuntimeError, 'unexpected probe bug')
  end

  it 'fails required nginx coverage when the executable was not configured' do
    with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => '1', 'OOD_TEST_NGINX_BIN' => nil) do
      expect(NginxStage::PunProcess).not_to receive(:check_signal_support!)
      expect do
        require_native_nginx!
      end.to raise_error(RuntimeError, /Required native coverage unavailable: .*OOD_TEST_NGINX_BIN/)
    end
  end

  it 'skips optional nginx coverage when the executable was not configured' do
    with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => nil, 'OOD_TEST_NGINX_BIN' => nil) do
      expect(self).to receive(:skip).with('set OOD_TEST_NGINX_BIN to run real nginx integration')
      expect(NginxStage::PunProcess).not_to receive(:check_signal_support!)
      require_native_nginx!
    end
  end

  it 'validates the configured nginx executable and the production signaling capability' do
    with_modified_env('OOD_REQUIRE_NATIVE_PUN_TESTS' => '1', 'OOD_TEST_NGINX_BIN' => '/bin/true') do
      allow(NginxStage::PunProcess).to receive(:check_signal_support!).and_return(true)
      expect(NginxStage::PunProcess).to receive(:check_signal_support!).once
      expect(require_native_nginx!).to eq('/bin/true')
    end
  end

  it 'rejects an invalid configured nginx path without silently skipping coverage' do
    with_modified_env('OOD_TEST_NGINX_BIN' => 'relative/nginx') do
      expect(self).not_to receive(:skip)
      expect { require_native_nginx! }.to raise_error(ArgumentError, /absolute executable path/)
    end
  end
end
