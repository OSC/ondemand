require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  include ApplicationHelper

  def setup
    @user_configuration = nil
  end

  test "profile_links should ignore configurations without profile property" do
    @user_configuration = stub(:profile_links => ['a', 'b', {profile: 'test_profile', title: 'My Profile'}, {page: 'c'}])

    result = profile_links

    assert_equal 1, result.size
    assert_equal 'My Profile', result[0][:title]
  end

  test "profile_links should add css class for dropdown items" do
    @user_configuration = stub(:profile_links => [{profile: 'test_profile', title: 'My Profile'}])

    result = profile_links

    assert_equal 1, result.size
    assert_equal 'dropdown-item', result[0][:class]
  end

  test "profile_links should delegate to NavBar to create links" do
    config = [{profile: 'test_profile', title: 'My Profile'}]
    @user_configuration = stub(:profile_links => config)

    NavBar.expects(:items).with(config).returns([])
    profile_links
  end

  test "custom_css_paths should prepend public_url to all custom css file paths" do
    @user_configuration = stub(:custom_css_files => ['/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['/custom/css/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/custom/css/test.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['custom/css/test.css'], :public_url => Pathname.new("/public"))
    assert_equal ['/public/custom/css/test.css'], custom_css_paths
  end

  test "custom_css_paths should should handle nil and empty file paths" do
    @user_configuration = stub(:custom_css_files => ['/test.css', nil, "other.css"], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => [nil], :public_url => Pathname.new("/public"))
    assert_equal [], custom_css_paths

    @user_configuration = stub(:custom_css_files => ['/test.css', "", "other.css"], :public_url => Pathname.new("/public"))
    assert_equal ['/public/test.css', '/public/other.css'], custom_css_paths

    @user_configuration = stub(:custom_css_files => [""], :public_url => Pathname.new("/public"))
    assert_equal [], custom_css_paths
  end
end
