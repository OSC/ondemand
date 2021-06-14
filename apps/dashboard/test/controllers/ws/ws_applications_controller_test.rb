require 'test_helper'


class Ws::WsApplicationsControllerTest < ActionController::TestCase

  def setup
    mock_application = mock("application")
    mock_application.stubs(:name).returns("app_name")
    mock_application.stubs(:type).returns("app_type")
    mock_application.stubs(:token).returns("app_token")
    mock_application.stubs(:role).returns("app_role")
    mock_application.stubs(:category).returns("app_category")
    mock_application.stubs(:subcategory).returns("app_subcategory")
    mock_application.stubs(:url).returns("app_url")
    mock_application.stubs(:path).returns("app_path")
    @applications = [mock_application]
  end

  test ":index should return the list of system applications installed" do
    SysRouter.stubs(:apps).returns(@applications)
    get :index

    assert_response :ok
    response_hash = JSON.parse(@response.body).deep_symbolize_keys
    assert_equal 1, response_hash[:items].length
    app_data = response_hash[:items][0]

    assert_equal "app_name", app_data[:name]
    assert_equal "app_type", app_data[:type]
    assert_equal "app_token", app_data[:token]
    assert_equal "app_role", app_data[:role]
    assert_equal "app_category", app_data[:category]
    assert_equal "app_subcategory", app_data[:subcategory]
    assert_equal "app_url", app_data[:url]
    assert_equal "app_path", app_data[:path]
  end

end