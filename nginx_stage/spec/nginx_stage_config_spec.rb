# frozen_string_literal: true

require 'nginx_stage'
require 'spec_helper'

describe NginxStage::Configuration do
  describe 'does config match with example file?' do
    it 'returns true if config matches example file' do
      public_inst_methods = described_class.public_instance_methods
      attr_setter_names = public_inst_methods
                          .map(&:to_s)
                          .select { |name| name.end_with?('=') }
                          .uniq

      config_opts = attr_setter_names.map { |name| name.delete('=') }
      example_config_opts = File.read('./share/nginx_stage_example.yml').scan(/#([\w_]+):/).flatten

      expect(config_opts + example_config_opts - (config_opts & example_config_opts)).to be_empty
    end
  end
end
