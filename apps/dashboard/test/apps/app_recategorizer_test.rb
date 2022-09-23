# frozen_string_literal: true

require 'test_helper'

class AppRecategorizerTest < ActiveSupport::TestCase
  def setup
    # Mock the sys installed applications
    SysRouter.stubs(:base_path).returns(Rails.root.join('test/fixtures/sys_with_gateway_apps'))
    OodAppkit.stubs(:clusters).returns(OodCore::Clusters.load_file('test/fixtures/config/clusters.d'))
  end

  def basic_app
    SysRouter.apps.find { |app| app.token == 'sys/bc_jupyter' }
  end

  def app_w_subapps
    SysRouter.apps.find { |app| app.token == 'sys/bc_desktop' }
  end

  test 'should create an OodApp with category and subcategory' do
    result = AppRecategorizer.new(stub, category: 'test_category', subcategory: 'test_subcategory', token: 'test/token')
    assert_equal 'test_category', result.category
    assert_equal 'test_subcategory', result.subcategory
    assert_equal 'test/token',  result.token
  end

  test 'AppRecategorizer should use apps defaults' do
    original = basic_app
    recategorized = AppRecategorizer.new(original)

    assert_equal original.category, recategorized.category
    assert_equal original.subcategory, recategorized.subcategory
    assert_equal original.token.to_s, recategorized.token.to_s
  end

  test 'can recategorize an app' do
    original = basic_app
    recategorized = AppRecategorizer.new(original, category: 'Test Feature')
    assert_equal 'Test Feature', recategorized.category
  end

  test 'can recategorize an app by subcategory' do
    original = basic_app
    recategorized = AppRecategorizer.new(original, subcategory: 'Test Sub Feature')
    assert_equal 'Test Sub Feature', recategorized.subcategory
  end

  test 'can set a new token' do
    original = basic_app
    recategorized = AppRecategorizer.new(original, token: 'sys/bc_desktop/owens')
    assert_equal 'sys/bc_desktop/owens', recategorized.token
  end

  test 'can set a new token, category and subcategory' do
    original = basic_app
    recategorized = AppRecategorizer.new(
      original,
      category:    'Test Feature',
      subcategory: 'Test Sub Feature',
      token:       'sys/bc_desktop/owens'
    )

    assert_equal 'sys/bc_desktop/owens', recategorized.token
    assert_equal 'Test Feature', recategorized.category
    assert_equal 'Test Sub Feature', recategorized.subcategory
  end

  test 'returns a single link for subapps' do
    original = app_w_subapps
    recategorized = AppRecategorizer.new(original, token: 'sys/bc_desktop/owens')
    links = recategorized.links

    # raise StandardError, original.inspect
    assert_equal 'sys/bc_desktop/owens', recategorized.token
    assert_equal 1, links.size
    assert_equal '/batch_connect/sys/bc_desktop/owens/session_contexts/new', links.first.url
  end

  test 'returns original links for regular apps' do
    original = basic_app
    recategorized = AppRecategorizer.new(original)
    links = recategorized.links

    # raise StandardError, original.inspect
    assert_equal 'sys/bc_jupyter', recategorized.token
    assert_equal 1, links.size
    assert_equal '/batch_connect/sys/bc_jupyter/session_contexts/new', links.first.url
  end

  test 'can recategorize many apps' do
    apps = SysRouter.apps
    apps.each do |app|
      assert app.category != 'test category'
    end

    AppRecategorizer.recategorize(apps, 'test category', nil).each do |app|
      assert app.category == 'test category'
      original = apps.find { |a| a.token == app.token }
      assert_equal original.subcategory, app.subcategory # keeps the original subcategory
    end
  end

  test 'can recategorize many apps by subcategory' do
    apps = SysRouter.apps
    apps.each do |app|
      assert app.subcategory != 'test subcategory'
    end

    AppRecategorizer.recategorize(apps, nil, 'test subcategory').each do |app|
      assert app.subcategory == 'test subcategory'
      original = apps.find { |a| a.token == app.token }
      assert_equal original.category, app.category # keeps the original category
    end
  end

  test 'can recategorize many apps by category and subcategory' do
    apps = SysRouter.apps
    apps.each do |app|
      assert app.category != 'test category'
      assert app.subcategory != 'test subcategory'
    end

    AppRecategorizer.recategorize(apps, 'test category', 'test subcategory').each do |app|
      assert app.category == 'test category'
      assert app.subcategory == 'test subcategory'

      assert_equal 'test category', app.category
      assert_equal 'test subcategory', app.subcategory

      # these differ from the original
      original = apps.find { |a| a.token == app.token }
      assert_not_equal original.category, app.category
      assert_not_equal original.subcategory, app.subcategory
    end
  end
end
