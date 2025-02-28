# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class AutoLogLocationTest < ActiveSupport::TestCase
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

    test 'correctly sets the user supplied value' do
      with_modified_env(dynamic_env) do
        options = {
          value: 'logerrific_locale',
          label: 'Log Location'
        }
        attribute = SmartAttributes::AttributeFactory.build('auto_log_location', options)

        assert_equal('logerrific_locale', attribute.value)
      end
    end

    test 'correctly sets the default value in place of empty string' do
      with_modified_env(dynamic_env) do
        options = {
          value: '',
          label: 'Log Location'
        }
        attribute = SmartAttributes::AttributeFactory.build('auto_log_location', options)

        assert_nil(attribute.value)
      end
    end

    test 'correctly sets the default value in place of nil string' do
      with_modified_env(dynamic_env) do
        options = {
          value: nil,
          label: 'Log Location'
        }
        attribute = SmartAttributes::AttributeFactory.build('auto_log_location', options)

        assert_nil(attribute.value)
      end
    end
  end
end
