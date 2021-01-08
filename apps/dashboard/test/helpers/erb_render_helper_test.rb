require 'test_helper'
require 'erb/erb_render_helper'

class ERBRenderHelperTest < ActionView::TestCase
  include ERBRenderHelper

  test 'groups array size should be > 0' do
    assert_equal groups.size > 0, true
  end

  test 'users group should exist in groups' do
    assert_equal user_in_group?(OodSupport::Group.new), true
  end
end
