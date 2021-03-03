require 'test_helper'

class CurrentUserSingletonTest < ActiveSupport::TestCase
  test 'groups array size should be > 0' do
    assert_equal CurrentUser.groups.size > 0, true
  end

  test 'users group should exist in groups' do
    assert_equal CurrentUser.user_in_group?(OodSupport::Group.new), true
  end
end
