# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class AutoOutputDirectoryTest < ActiveSupport::TestCase
    def setup
      stub_clusters
      stub_user
      stub_sacctmgr
    end

    def dynamic_env
      {
        OOD_BC_DYNAMIC_JS:   'true'
      }
    end

    test 'correctly sets the value' do
      with_modified_env(dynamic_env) do
        options = {
          value: 'output_extravaganza',
          label: 'Output Directory'
        }
        attribute = SmartAttributes::AttributeFactory.build('auto_output_directory', options)

        assert_equal('output_extravaganza', attribute.value.to_s)
      end
    end
  end
end
