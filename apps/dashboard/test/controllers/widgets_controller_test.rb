require 'test_helper'
require 'html_helper'

class WidgetsControllerTest < ActionController::TestCase

  def setup
    Configuration.stubs(:widget_images_path).returns(nil)
  end

  test "should return 400 when widget_images_path is not configured" do
    Configuration.stubs(:widget_images_path).returns(nil)
    get :image, params: { image_name: "test.png" }
    assert_response :bad_request
  end

  test "should return 400 when widget_images_path is configured and image type is not supported" do
    Configuration.stubs(:widget_images_path).returns("#{Rails.root}/test/fixtures/widgets/images")
    get :image, params: { image_name: "test.avi" }
    assert_response :bad_request
  end

  test "should return 404 when widget_images_path is configured and image not installed" do
    Configuration.stubs(:widget_images_path).returns("#{Rails.root}/test/fixtures/widgets/images")
    get :image, params: { image_name: "test.png" }
    assert_response :not_found
  end

end
