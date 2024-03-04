# frozen_string_literal: true

require 'test_helper'

class LaunchersHelperTest < ActionView::TestCase
  include LaunchersHelper

  test 'launcher_removable_field? should return false for expected fields' do
    assert_equal true, script_removable_field?('any_field')

    non_removable_fields = ['launcher_auto_scripts', 'launcher_auto_batch_clusters']
    non_removable_fields.each do |field|
      assert_equal false, script_removable_field?(field)
    end
  end
end
