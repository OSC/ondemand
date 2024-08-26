# frozen_string_literal: true

require 'test_helper'

class BatchConnectConcernTest < ActiveSupport::TestCase
  url_helpers = Rails.application.routes.url_helpers

  class TestClass
    include BatchConnectConcern

    attr_accessor :user_configuration, :nav_bar
  end

  def setup
    # Defaults
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
    @target = TestClass.new
    @target.user_configuration = stub(:interactive_apps_menu => [])
    @target.nav_bar = []
  end

  test 'bc_custom_apps_group should return nil when no interactive_apps_menu and nav_bar defined' do
    assert_nil @target.bc_custom_apps_group
  end

  test 'bc_custom_apps_group should return a navigation menu based on interactive_apps_menu property when defined' do
    @target.user_configuration = stub(:interactive_apps_menu => { title: 'Custom Apps Menu', links: [] })

    result = @target.bc_custom_apps_group

    assert_equal 'Custom Apps Menu', result.title
    assert_equal [], result.apps
    # Sorting should be disabled. Use the order in the configuration
    assert_equal false, result.sort
  end

  test 'bc_custom_apps_group should return a navigation menu based on @nav_bar when interactive_apps_menu is not defined and @nav_bar is' do
    @target.nav_bar = NavBar.items([{ title: 'Primary Menu', apps: 'sys/bc_jupyter' },
                                    { title: 'Secondary Menu', apps: 'sys/bc_paraview' }])
    @target.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('menu title from translation')

    result = @target.bc_custom_apps_group

    assert_equal 'menu title from translation', result.title
    assert_equal 2, result.apps.size
    assert_equal [url_helpers.new_batch_connect_session_context_path('sys/bc_jupyter'), url_helpers.new_batch_connect_session_context_path('sys/bc_paraview')],
                 result.apps.map(&:links).flatten.map(&:url)
    # Sorting should be enabled. Apps come from different menus in the navigation
    assert_equal true, result.sort
  end

  test 'bc_custom_apps_group should dedupe links when app links are based on configured @nav_bar applications' do
    @target.nav_bar = NavBar.items([{ title: 'Primary Menu', apps: 'sys/bc_jupyter' },
                                    { title: 'Secondary Menu', apps: 'sys/bc_jupyter' }])
    @target.expects(:t).with('dashboard.batch_connect_apps_menu_title').returns('menu title from translation')

    result = @target.bc_custom_apps_group

    assert_equal 'menu title from translation', result.title
    assert_equal 1, result.apps.size
    assert_equal [url_helpers.new_batch_connect_session_context_path('sys/bc_jupyter')],
                 result.apps.map(&:links).flatten.map(&:url)
    # Sorting should be enabled. Apps come from different menus in the navigation
    assert_equal true, result.sort
  end
end
