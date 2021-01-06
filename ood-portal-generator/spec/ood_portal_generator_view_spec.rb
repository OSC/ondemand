require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__

describe OodPortalGenerator::View do
  describe 'dodes config opts match with example opts?' do
    it 'returns true if opts match' do
      config_opts = OodPortalGenerator::View.new
        .instance_variables.map(&:to_s).map { |opt| opt.delete("@") }
      example_config_opts = File.read(
          './share/ood_portal_example.yml').scan(/#[\w_]+:/)
      
      # delete inst vars that are not actual options in the example file
      config_opts.delete('protocol')
      config_opts.delete('oidc_redirect_uri')
      config_opts.delete('oidc_crypto_passphrase')

      config_opts.map(&:to_s).each do |opt|
        expect(example_config_opts).to opt_exists?(opt)  
      end
    end
  end
end

