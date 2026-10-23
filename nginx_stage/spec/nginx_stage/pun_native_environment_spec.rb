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
end
