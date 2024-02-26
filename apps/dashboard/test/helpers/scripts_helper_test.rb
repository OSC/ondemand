# frozen_string_literal: true

require 'test_helper'

class ScriptsHelperTest < ActionView::TestCase
  include ScriptsHelper

  test 'script_removable_field? should return false for expected fields' do
    assert_equal true, script_removable_field?('any_field')

    non_removable_fields = ['script_auto_scripts', 'script_auto_batch_clusters']
    non_removable_fields.each do |field|
      assert_equal false, script_removable_field?(field)
    end
  end
end
