# frozen_string_literal: true

require 'application_system_test_case'

class ProductsUsrTest < ApplicationSystemTestCase
  # Only testing show and index actions for type :usr
  # ProductsDevTest used for testing page interactions

  def setup
    stub_usr_router
    setup_usr_fixtures
  end

  def teardown
    teardown_usr_fixtures
  end

  test 'Index of my_shared_app can be accessed' do
    UsrRouter.stubs(:base_path).returns(Pathname.new('test/fixtures/usr/me'))
    visit products_path(:usr)
  end

  test 'Show of my_shared_app url can be accessed' do
    visit product_path(:usr, 'my_shared_app')
  end
end
