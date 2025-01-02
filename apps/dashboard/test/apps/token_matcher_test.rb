# frozen_string_literal: true

require 'test_helper'

class TokenMatcherTest < ActiveSupport::TestCase
  test 'token should return token parameter' do
    target = TokenMatcher.new('sys/app')
    assert_equal('sys/app', target.token)

    target = TokenMatcher.new({ token: 'sys/app', type: 'sys' })
    assert_equal({ token: 'sys/app', type: 'sys' }, target.token)
  end

  test 'app token should match app' do
    target = TokenMatcher.new('sys/app')
    app = OodApp.new(Router.router_from_token('sys/app'))
    assert_equal true, target.matches_app?(app)
  end

  test 'app token should not match app with the same prefix' do
    target = TokenMatcher.new('sys/app')
    app = OodApp.new(Router.router_from_token('sys/app_prefix'))
    assert_equal false, target.matches_app?(app)
  end

  test 'app token with asterisk should match app with the same prefix' do
    target = TokenMatcher.new('sys/app*')
    app = OodApp.new(Router.router_from_token('sys/app_prefix'))
    assert_equal true, target.matches_app?(app)
  end

  test 'app token should match sub app' do
    target = TokenMatcher.new('sys/app')
    app = BatchConnect::App.from_token('sys/app/sub_app')
    assert_equal true, target.matches_app?(app)
  end

  test 'app token with trailing slash should match sub app' do
    target = TokenMatcher.new('sys/app/')
    app = BatchConnect::App.from_token('sys/app/sub_app')
    assert_equal true, target.matches_app?(app)
  end

  test 'sub app token should match sub app' do
    target = TokenMatcher.new('sys/app/sub_app')
    app = BatchConnect::App.from_token('sys/app/sub_app')
    assert_equal true, target.matches_app?(app)
  end

  test 'sub app token should not match different sub app' do
    target = TokenMatcher.new('sys/app/sub_app')
    app = BatchConnect::App.from_token('sys/app/different_sub_app')
    assert_equal false, target.matches_app?(app)
  end

  test 'sub app token should not match app' do
    target = TokenMatcher.new('sys/app/sub_app')
    app = OodApp.new(Router.router_from_token('sys/app'))
    assert_equal false, target.matches_app?(app)
  end

  test 'type, category, and subcategory should not trigger metadata match' do
    [:other, :items, :should, :match].each do |item|
      target = TokenMatcher.new({ item => 'value' })
      assert_equal true, target.matchers.any? { |matcher|
                           matcher == 'metadata_match?'
                         }, "Expected field: #{item} to create a metadata_match? matcher"
    end

    [:type, :category, :subcategory].each do |item|
      target = TokenMatcher.new({ item => 'value' })
      assert_equal false, target.matchers.any? { |matcher|
                            matcher == 'metadata_match?'
                          }, "Expected field: #{item} not to create a metadata_match? matcher"
    end
  end
end
