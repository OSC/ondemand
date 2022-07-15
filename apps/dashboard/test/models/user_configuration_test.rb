require 'test_helper'

class UserConfigurationTest < ActiveSupport::TestCase

  DEFAULT_CONFIG = {
    key_1: "default_value_1",
    key_2: "default_value_2",
    key_3: "default_value_3",
    key_4: nil,
    profiles: {
      profile_test: {
        key_1: "test_value_1",
        key_2: "test_value_2",
        key_3: nil
      }
    }
  }

  test "pinned_apps_group_by returns original category when configured with category" do
    Configuration.stubs(:config).returns({pinned_apps_group_by: "category"})
    assert_equal "original_category", UserConfiguration.new.pinned_apps_group_by
  end

  test "pinned_apps_group_by returns original subcategory when configured with subcategory" do
    Configuration.stubs(:config).returns({pinned_apps_group_by: "subcategory"})
    assert_equal "original_subcategory", UserConfiguration.new.pinned_apps_group_by
  end

  test "pinned_apps_group_by returns an empty string by default" do
    Configuration.stubs(:config).returns({})
    assert_equal "", UserConfiguration.new.pinned_apps_group_by
  end

  test "reads pinned apps from config" do
    pinned_apps = [
      "sys/bc_osc_jupyter",
      "sys/bc_osc_rstudio_server",
      "sys/iqmol",
      {
        type: 'sys',
        category: 'Interactive Apps',
        subcategory: 'Servers',
        field_of_science: 'Biology'
      }
    ]

    Configuration.stubs(:config).returns({ pinned_apps: pinned_apps })
    CurrentUser.stubs(:user_settings).returns({})

    assert_equal pinned_apps, UserConfiguration.new.pinned_apps
  end

  test "profile should delegate to CurrentUser settings" do
    target = UserConfiguration.new
    CurrentUser.stubs(:user_settings).returns({profile: "user_settings_profile_value"})

    assert_equal :user_settings_profile_value, target.profile
  end

  test "fetch should use key as symbol" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({profile: "profile_test"})
    target = UserConfiguration.new

    assert_equal "test_value_1", target.send(:fetch, "key_1")
    assert_equal "test_value_2", target.send(:fetch, "key_2")
  end

  test "fetch should use the profile value when profile defines a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({profile: "profile_test"})
    target = UserConfiguration.new

    assert_equal "test_value_1", target.send(:fetch, :key_1)
    assert_equal "test_value_2", target.send(:fetch, :key_2)
  end

  test "fetch should use the root configuration value when profile do not define a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({})
    target = UserConfiguration.new

    assert_nil target.profile
    assert_equal "default_value_3", target.send(:fetch, :key_3)
  end

  test "fetch should use the default value when the profile and root configurations do not define a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({profile: "profile_test"})
    target = UserConfiguration.new

    assert_equal "default_value_argument", target.send(:fetch, :missing_key, "default_value_argument")
  end

  test "fetch should use the profile value when is define but null" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({profile: "profile_test"})
    target = UserConfiguration.new

    assert_nil target.send(:fetch, :key_3, "default")
  end

  test "fetch should use the root value when is define but null and not defined in profile" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({profile: "profile_test"})
    target = UserConfiguration.new

    assert_nil target.send(:fetch, :key_4, "default")
  end

  test "fetch should handle nil keys" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    CurrentUser.stubs(:user_settings).returns({})
    target = UserConfiguration.new

    assert_nil target.send(:fetch, nil)
    assert_equal "default_value_argument", target.send(:fetch, nil, "default_value_argument")
  end

end