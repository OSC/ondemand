require 'test_helper'

class ERBRenderHelperTest < ActionView::TestCase
  test 'groups array size should be > 0' do
    assert_equal groups.size > 0, true
  end

  test 'users group should exist in groups' do
    assert_equal user_in_group?(OodSupport::Group.new), true
  end
end
