require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__

describe OodPortalGenerator::View do
  describe 'does config opts match with example opts?' do
    it 'returns true if opts match' do
      config_opts = OodPortalGenerator::View.new
          .instance_variables
          .map(&:to_s)
          .map { |opt| opt.delete("@") }
      
      example_config_opts = File.read('./share/ood_portal_example.yml').scan(/#([\w_]+):/).flatten

      # remove dex as it's not part of the view
      example_config_opts -= %w(dex) 
      
      # delete inst vars that are not actual options in the example file
      config_opts -= %w(protocol allowed_hosts oidc_redirect_uri oidc_crypto_passphrase dex_http_port)

      expect(config_opts + example_config_opts - (config_opts & example_config_opts)).to be_empty
    end
  end
end

