require 'test_helper'

class BatchConnectConcernTest < ActiveSupport::TestCase

  class TestClass
    include BatchConnectConcern

    attr_accessor :user_configuration, :nav_bar
  end

  def setup
    # Defaults
    @target = TestClass.new
    @target.user_configuration = stub(:interactive_apps_menu => [])
    @target.nav_bar = []
  end

  test "bc_custom_apps_group should return nil when no interactive_apps_menu and nav_bar defined" do
    assert_nil @target.bc_custom_apps_group
  end

  test "bc_custom_apps_group should return a navigation menu based on interactive_apps_menu property when defined" do
    @target.user_configuration = stub(:interactive_apps_menu => {title: "Custom Apps Menu", links: []})

    result = @target.bc_custom_apps_group

    assert_equal 'Custom Apps Menu', result.title
    assert_equal [], result.apps
    # Sorting should be disabled. Use the order in the configuration
    assert_equal false, result.sort
  end

  test "bc_custom_apps_group should return a navigation menu based on @nav_bar when interactive_apps_menu is not defined and @nav_bar is" do
    nav_item = OodAppGroup.new(apps: [], title: "test title")
    @target.nav_bar = [nav_item]
    @target.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('menu title from translation')

    result = @target.bc_custom_apps_group

    assert_equal 'menu title from translation', result.title
    assert_equal [], result.apps
    # Sorting should be enabled. Apps come from different menus in the navigation
    assert_equal true, result.sort
  end

end