require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest

  def setup
    # lot's of setup here to get a valid csrf-token
    get root_path
    assert :success

    doc = Nokogiri::XML(@response.body)
    @token = doc.xpath("/html/head/meta[@name='csrf-token']/@content").to_s
    @headers = { 'X-CSRF-Token' => @token }
  end

  test "should call Configuration.update_user_settings when posting settings data" do
    data = {
      settings: {
        profile: "test_profile"
      }
    }
    Dir.mktmpdir {|temp_data_dir|
      Configuration.stubs(:dataroot).returns(temp_data_dir)
      CurrentUser.expects(:update_user_settings).with({ "profile" => "test_profile" }).once

      post settings_path, params: data, headers: @headers
      assert_response :redirect
    }
  end

  test "should not call Configuration.update_user_settings when no data" do
    data = { settings: { } }
    CurrentUser.expects(:update_user_settings).never

    post settings_path, params: data, headers: @headers
    assert_response :redirect
  end

  test "parameters outside the settings namespace should be ignored" do
    data = { profile: "root_value" }
    CurrentUser.expects(:update_user_settings).never

    post settings_path, params: data, headers: @headers
    assert_response :redirect
  end

end