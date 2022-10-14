require 'test_helper'

class TokenMatcherTest < ActiveSupport::TestCase

  test "app token should match app" do
    target = TokenMatcher.new("sys/app")
    app = OodApp.new(Router.router_from_token("sys/app"))
    assert_equal true, target.matches_app?(app)
  end

  test "app token should match sub app" do
    target = TokenMatcher.new("sys/app")
    app = OodApp.new(Router.router_from_token("sys/app/sub_app"))
    assert_equal true, target.matches_app?(app)
  end

  test "sub app token should match sub app" do
    target = TokenMatcher.new("sys/app/sub_app")
    app = BatchConnect::App.from_token("sys/app/sub_app")
    assert_equal true, target.matches_app?(app)
  end

  test "sub app token should not match different sub app" do
    target = TokenMatcher.new("sys/app/sub_app")
    app = BatchConnect::App.from_token("sys/app/different_sub_app")
    assert_equal false, target.matches_app?(app)
  end

  test "sub app token should not match app" do
    target = TokenMatcher.new("sys/app/sub_app")
    app = OodApp.new(Router.router_from_token("sys/app"))
    assert_equal false, target.matches_app?(app)
  end

end