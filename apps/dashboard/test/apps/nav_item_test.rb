require 'test_helper'

class NavItemTest < ActiveSupport::TestCase

  test "type should return the provided type" do
    assert_equal :nav_menu,  NavBar::NavItem.new(:nav_menu, {}).type
  end

  test "title should default to nil when not provided" do
    assert_nil NavBar::NavItem.new(:type_name, {}).title
  end

  test "title should return provided property value" do
    nav_item_config = {title: "Nav Item Title"}
    assert_equal "Nav Item Title", NavBar::NavItem.new(:type_name, nav_item_config).title
  end

  test "url should default to nil when not provided" do
    assert_nil NavBar::NavItem.new(:type_name, {}).url
  end

  test "url should return provided property value" do
    nav_item_config = {url: "/nav/url"}
    assert_equal "/nav/url", NavBar::NavItem.new(:type_name, nav_item_config).url
  end

  test "icon should default to cog when not provided" do
    assert_equal URI("fas://cog"),  NavBar::NavItem.new(:type_name, {}).icon
  end

  test "icon should return provided property value" do
    nav_item_config = {icon: "fa://test_icon"}
    assert_equal URI("fa://test_icon"), NavBar::NavItem.new(:type_name, nav_item_config).icon
  end

  test "new_tab should default to true when not provided" do
    assert_equal true,  NavBar::NavItem.new(:type_name, {}).new_tab
  end

  test "new_tab should return provided property value" do
    nav_item_config = {new_tab: false}
    assert_equal false, NavBar::NavItem.new(:type_name, nav_item_config).new_tab
  end

  test "new_tab should convert string properties values to true" do
    nav_item_config = {new_tab: "true"}
    assert_equal true, NavBar::NavItem.new(:type_name, nav_item_config).new_tab

    nav_item_config = {new_tab: "false"}
    assert_equal true, NavBar::NavItem.new(:type_name, nav_item_config).new_tab

    nav_item_config = {new_tab: "error"}
    assert_equal true, NavBar::NavItem.new(:type_name, nav_item_config).new_tab
  end

  test "profile attributes should be set when profile property is provided" do
    nav_item_config = {title: "profile title", profile: "profile1"}

    target = NavBar::NavItem.new(:type_name, nav_item_config)
    expected_data_property = {method: "post"}
    assert_equal "profile title", target.title
    assert_equal false, target.new_tab
    assert_equal expected_data_property, target.data
    assert_equal  Rails.application.routes.url_helpers.settings_path("settings[profile]" => "profile1"), target.url
  end

  test "title should default to profile when no title provided and profile property is set" do
    nav_item_config = {profile: "profile1"}

    target = NavBar::NavItem.new(:type_name, nav_item_config)
    assert_equal "profile1", target.title
  end

  test "links should default to nil when no app or tokens property provided" do
    assert_nil NavBar::NavItem.new(:type_name, {}).links
  end

  test "links should return OodApp.links when app property is provided" do
    expected_link_list = [OodAppLink.new]
    ood_app_mock = stub({manifest: stub({:valid? => true}), links: expected_link_list})
    OodApp.stubs(:new).returns(ood_app_mock)

    nav_item_config = {app: "sys/mock"}
    assert_equal expected_link_list, NavBar::NavItem.new(:type_name, nav_item_config).links
  end

  test "links should return SysRouter apps that match the tokens provided with the tokens property" do
    expected_link_list = [OodAppLink.new]
    featured_app_mock = stub({links: expected_link_list})
    app_list = [featured_app_mock]
    Router.stubs(:feature_apps).with(["sys/mock"], SysRouter.apps).returns(app_list)

    nav_item_config = {tokens: ["sys/mock"]}
    assert_equal expected_link_list, NavBar::NavItem.new(:type_name, nav_item_config).links
  end

  test "links should return empty array when invalid router provided in app configuration" do
    nav_item_config = {app: "invalid_router/app"}
    assert_equal [], NavBar::NavItem.new(:type_name, nav_item_config).links
  end

  test "links should return empty array when invalid sys app provided" do
    nav_item_config = {app: "sys/invalid"}
    assert_equal [], NavBar::NavItem.new(:type_name, nav_item_config).links
  end

  test "template should be based on the type name when no template property provided" do
    assert_equal "layouts/nav/custom/type_name",  NavBar::NavItem.new(:type_name, {}).template
  end

  test "template should be based on the template property when provided" do
    nav_item_config = {template: "path/to/template"}
    assert_equal "layouts/nav/path/to/template",  NavBar::NavItem.new(:type_name, nav_item_config).template

    nav_item_config = {template: "/path/to/template"}
    assert_equal "layouts/nav/path/to/template",  NavBar::NavItem.new(:type_name, nav_item_config).template
  end

end