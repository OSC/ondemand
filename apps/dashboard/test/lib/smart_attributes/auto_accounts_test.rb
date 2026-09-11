# frozen_string_literal: true

require 'test_helper'
require 'smart_attributes'

module SmartAttributes
  class AutoAccountsTest < ActiveSupport::TestCase
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

    test 'correctly sets the value when previous value cannot be found' do
      with_modified_env(dynamic_env) do
        options = {
          options:         [['pzs1118', 'pzs1118', {}], ['pzs0715', 'pzs0715', {}], ['pzs0714', 'pzs0714', {}],
                            ['pzs1117', 'pzs1117', { 'data-option-for-cluster-ruby'=>false }], ['pas1604', 'pas1604', { 'data-option-for-cluster-ruby'=>false }]],
          value:           'pzs0714',
          exclude_options: ['pzs1118', 'pzs1117', 'pas1604', 'pzs0715'],
          fixed:           true
        }
        attribute = SmartAttributes::AttributeFactory.build('auto_accounts', options)

        assert_equal('pzs0714', attribute.value.to_s)
      end
    end

    test 'dynamic_accounts hyphenates underscores in data-option-for-cluster keys' do
      Rails.cache.clear
      Configuration.stubs(:job_clusters).returns([stub(id: 'owens'), stub(id: 'x-nextgen_ascend')])
      SmartAttributes::AttributeFactory.stubs(:accounts).returns([stub(name: 'pzs0714', cluster: 'owens', to_s: 'pzs0714')])

      data = SmartAttributes::AttributeFactory.dynamic_accounts.find { |t| t[0] == 'pzs0714' }.last
      assert data.key?('data-option-for-cluster-x-nextgen-ascend')
    end
  end
end
