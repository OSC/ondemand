# frozen_string_literal: true

require 'test_helper'

class NavConfigTest < ActiveSupport::TestCase
  def setup
    # reset defaults for every test
    NavConfig.categories = ['Apps', 'Files', 'Jobs', 'Clusters', 'Interactive Apps']
    NavConfig.categories_allowlist = false
  end

  def teardown
    # reset defaults for every test
    NavConfig.categories = ['Apps', 'Files', 'Jobs', 'Clusters', 'Interactive Apps']
    NavConfig.categories_allowlist = false
  end

  test 'default values' do
    assert_equal(false, NavConfig.categories_allowlist?)
    assert_equal(false, NavConfig.categories_allowlist)
    assert_equal(['Apps', 'Files', 'Jobs', 'Clusters', 'Interactive Apps'], NavConfig.categories)

    assert_equal(false, NavConfig.categories_whitelist?)
    assert_equal(false, NavConfig.categories_whitelist)
  end

  test 'can set allowlist' do
    NavConfig.categories = ['the only one']
    NavConfig.categories_allowlist = true

    assert_equal(true, NavConfig.categories_allowlist?)
    assert_equal(true, NavConfig.categories_allowlist)
    assert_equal(true, NavConfig.categories_whitelist?)
    assert_equal(true, NavConfig.categories_whitelist)
    assert_equal(['the only one'], NavConfig.categories)
  end

  test 'can set whitelist' do
    NavConfig.categories = ['the only one']
    NavConfig.categories_whitelist = true

    assert_equal(true, NavConfig.categories_allowlist?)
    assert_equal(true, NavConfig.categories_allowlist)
    assert_equal(true, NavConfig.categories_whitelist?)
    assert_equal(true, NavConfig.categories_whitelist)
    assert_equal(['the only one'], NavConfig.categories)
  end
end
