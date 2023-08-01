# frozen_string_literal: true

require 'test_helper'

class ProductsTest < ActionDispatch::IntegrationTest
  test 'sandbox_apps_accessible_if_app_development_enabled' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:app_development_enabled?).returns(true)
      Configuration.stubs(:dev_apps_root_path).returns(Pathname.new(dir))

      get '/admin/dev/products'
      assert_response :success
    end
  end

  test 'sandbox_apps_not_accessible_if_app_development_disabled' do
    Configuration.stubs(:app_development_enabled?).returns(false)

    assert_raises(ActionController::RoutingError) do
      get '/admin/dev/products'
    end
  end
end
