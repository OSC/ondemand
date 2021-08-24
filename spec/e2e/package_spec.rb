# frozen_string_literal: true

require 'spec_helper_e2e'

describe 'OnDemand installed with packages' do
  describe package('ondemand') do
    it { is_expected.to be_installed }
  end
end
