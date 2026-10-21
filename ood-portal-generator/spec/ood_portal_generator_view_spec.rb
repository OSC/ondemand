# frozen_string_literal: true

require 'spec_helper'
require File.expand_path '../lib/ood_portal_generator', __dir__

describe OodPortalGenerator::View do
  describe 'does config opts match with example opts?' do
    it 'returns true if opts match' do
      config_opts = described_class.new
                                   .instance_variables
                                   .map(&:to_s)
                                   .map { |opt| opt.delete('@') }

      example_config_opts = File.read('./share/ood_portal_example.yml').scan(/#([\w_]+):/).flatten

      # remove dex as it's not part of the view
      example_config_opts -= ['dex']

      # delete inst vars that are not actual options in the example file
      config_opts -= ['protocol', 'allowed_hosts', 'dex_http_port']

      expect(config_opts + example_config_opts - (config_opts & example_config_opts)).to be_empty
    end
  end

  describe 'secure_rnode_ports' do
    it 'does not set an allowlist environment value by default' do
      expect(described_class.new.secure_rnode_ports_env).to be_nil
    end

    it 'normalizes a bounded explicit port allowlist' do
      view = described_class.new(secure_rnode_ports: [8443, '443', 443])
      expect(view.secure_rnode_ports_env).to eq('443,8443')
    end

    it 'rejects invalid ports and oversized lists' do
      [443, [], [0], [65_536], ['443x'], (1..65).to_a].each do |ports|
        expect { described_class.new(secure_rnode_ports: ports) }.to raise_error(ArgumentError)
      end
    end
  end
end
