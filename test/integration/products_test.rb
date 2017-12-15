require 'test_helper'

class ProductsTest < ActionDispatch::IntegrationTest
  test "sandbox_apps_accessible_if_app_development_enabled" do
    Configuration.stubs(:app_development_enabled?).returns(true)

    get "/admin/dev/products"
    assert_response :success

    Configuration.unstub(:app_development_enabled?)
  end

  test "sandbox_apps_not_accessible_if_app_development_disabled" do
    Configuration.stubs(:app_development_enabled?).returns(false)

    assert_raises(ActionController::RoutingError) do
      get "/admin/dev/products"
    end

    Configuration.unstub(:app_development_enabled?)
  end
end
