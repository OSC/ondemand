require "test_helper"

class CustomPagesControllerTest < ActiveSupport::TestCase

  test "index should set flash message if page_code configuration is not found" do
    target = CustomPagesController.new
    target.instance_variable_set(:@user_configuration, stub("user_configuration", {custom_pages: {}}))
    target.stubs(:params).returns({page_code: "not_found_page"})
    flash = ActionDispatch::Request.empty.flash
    target.stubs(:flash).returns(flash)
    target.expects(:t).with("dashboard.custom_pages.invalid", {:page => "not_found_page"})

    target.index
  end

  test "index should not set flash message if page_code configuration is found" do
    page_config = {
      rows: []
    }
    target = CustomPagesController.new
    target.instance_variable_set(:@user_configuration, stub("user_configuration", {custom_pages: {test_page: page_config}}))
    target.stubs(:params).returns({page_code: "test_page"})
    target.expects(:flash).times(0)

    target.index
  end

end