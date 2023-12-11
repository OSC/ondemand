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

  test "should save user_settings when posting settings data" do
    data = {
      settings: {
        profile: "test_profile"
      }
    }
    Dir.mktmpdir {|temp_data_dir|
      Configuration.stubs(:dataroot).returns(temp_data_dir)

      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_equal "test_profile", TestUserSettings.new.user_settings[:profile]
    }
  end

  test "should not save user settings when no data" do
    data = { settings: {} }

    Dir.mktmpdir {|temp_data_dir|
      Configuration.stubs(:dataroot).returns(temp_data_dir)
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_nil TestUserSettings.new.user_settings[:profile]
    }
  end

  test "should not save user_settings whne parameters are outside the settings namespace" do
    data = { profile: "root_value" }

    Dir.mktmpdir {|temp_data_dir|
      Configuration.stubs(:dataroot).returns(temp_data_dir)
      post settings_path, params: data, headers: @headers
      assert_response :redirect
      assert_nil TestUserSettings.new.user_settings[:profile]
    }
  end

  class TestUserSettings
    include UserSettingStore
  end

end