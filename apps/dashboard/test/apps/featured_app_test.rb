require 'test_helper'

class FeaturedAppTest < ActiveSupport::TestCase

  def setup
    # Mock the sys installed applications
    SysRouter.stubs(:base_path).returns(Rails.root.join("test/fixtures/sys_with_gateway_apps"))
  end

  test "FeaturedApp.from_ood_app should initialize object correctly" do
    app = OodApp.new(Router.router_from_token("sys/token"))

    target = FeaturedApp.from_ood_app(app, token: "other/token")
    assert_equal "Apps", target.category
    assert_equal "Pinned Apps", target.subcategory
    assert_equal "other/token", target.token
    assert_equal "sys/token", target.router.token
  end

  test "FeaturedApp.category can be set on creation" do
    target = FeaturedApp.new(Router.router_from_token("sys/token"), category: "Test Feature")
    assert_equal "Test Feature", target.category
  end

  test "FeaturedApp.subcategory can be set on creation" do
    target = FeaturedApp.new(Router.router_from_token("sys/token"), subcategory: "Test Sub Feature")
    assert_equal "Test Sub Feature", target.subcategory
  end

  test "FeaturedApp.sub_app_list should return a single BatchConnect::App for sub apps" do
    # Given a token for a sub app
    token = "sys/bc_desktop/oakley"
    # And a application with 2 sub apps "sys/bc_desktop"
    ood_app = OodApp.new(Router.router_from_token(token))
    assert_equal 2, ood_app.send(:sub_app_list).size

    # When a FeatureApp is created
    target = FeaturedApp.new(Router.router_from_token(token), token: token)
    # Then sub_app_list only contains the sub app driven by the token"
    assert_equal [BatchConnect::App.from_token(token)], target.send(:sub_app_list)
    assert_equal "oakley", target.send(:sub_app_name)
  end

  test "FeaturedApp.sub_app_list should return a single BatchConnect::App for apps" do
    # Given a token for a sub app
    token = "sys/bc_jupyter"
    # And a application with no sub apps "sys/bc_jupyter"
    ood_app = OodApp.new(Router.router_from_token(token))
    assert_equal 1, ood_app.send(:sub_app_list).size

    # When a FeatureApp is created
    target = FeaturedApp.new(Router.router_from_token(token), token: token)
    # Then sub_app_list only contains the sub app driven by the token"
    assert_equal [BatchConnect::App.from_token(token)], target.send(:sub_app_list)
    assert_equal "bc_jupyter", target.send(:sub_app_name)
  end

end