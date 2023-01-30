require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  include ApplicationHelper

  def setup
    @user_configuration = nil
  end

  test "help_links should include server restart" do
    @user_configuration = stub({ profile_links: [], help_menu: [] })

    result = help_links

    assert_equal 1,  result.apps.size
    assert_equal I18n.t('dashboard.nav_restart_server'),  result.apps[0].title
  end

  test "help_links should combine server restart with profile_links and help_menu" do
    @user_configuration = stub({ profile_links: [{title: "profile link", url: "/path"}], help_menu: [{title: "help link", url: "/path"}] })

    result = help_links

    assert_equal 3,  result.apps.size
    assert_equal I18n.t('dashboard.nav_restart_server'),  result.apps[0].title
    assert_equal "profile link",  result.apps[1].title
    assert_equal "help link",  result.apps[2].title
  end

  test "help_links should delegate to NavBar to create links" do
    config = { links: ["restart"] }
    @user_configuration = stub({ profile_links: [], help_menu: [] })

    NavBar.expects(:menu_items).with(config)
    help_links
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
