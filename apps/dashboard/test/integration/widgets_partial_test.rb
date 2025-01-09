require 'html_helper'
require 'test_helper'

class WidgetsPartialTest < ActionDispatch::IntegrationTest

  def setup
    Configuration.stubs(:widget_partials_enabled?).returns(true)
    Rails.application.reload_routes!
  end

  test 'should not load widgets partial route when widget_partials_enabled? is false' do
    Configuration.stubs(:widget_partials_enabled?).returns(false)
    Rails.application.reload_routes!

    refute respond_to?(:widgets_url)
  end

  test 'should render widget partial without any layout furniture' do
    get widgets_url('widgets_partial_test')

    assert_response :ok
    assert_equal '<h3>test response from widget partial</h3>', @response.body
  end

  test 'should render return 404 response when widget is missing' do
    get widgets_url('missing_widget')

    assert_response :not_found
  end
end
