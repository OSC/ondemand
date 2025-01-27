require 'test_helper'

class UserConfigurationTest < ActiveSupport::TestCase

  DEFAULT_CONFIG = {
    key_1: "default_value_1",
    key_2: "default_value_2",
    key_3: "default_value_3",
    key_4: nil,
    key_array: ["array_value"],
    profiles: {
      profile_test: {
        key_1: "test_value_1",
        key_2: "test_value_2",
        key_3: nil
      }
    }
  }

  ENVIRONMENT_PROPERTIES = {
    'OOD_DASHBOARD_HEADER_IMG_LOGO' => [:dashboard_header_img_logo, "setup-#{SecureRandom.uuid}"],
    'OOD_DISABLE_DASHBOARD_LOGO' => [:disable_dashboard_logo, true],
    'DISABLE_DASHBOARD_LOGO' => [:disable_dashboard_logo, true],
    'OOD_DASHBOARD_LOGO' => [:dashboard_logo, "setup-#{SecureRandom.uuid}"],
    'OOD_DASHBOARD_LOGO_HEIGHT' => [:dashboard_logo_height, "setup-#{SecureRandom.uuid}"],
    'OOD_DASHBOARD_TITLE' => [:dashboard_title, "setup-#{SecureRandom.uuid}"],

    'OOD_BRAND_BG_COLOR' => [:brand_bg_color, "setup-#{SecureRandom.uuid}"],
    'BOOTSTRAP_NAVBAR_DEFAULT_BG' => [:brand_bg_color, "setup-#{SecureRandom.uuid}"],
    'BOOTSTRAP_NAVBAR_INVERSE_BG' => [:brand_bg_color, "setup-#{SecureRandom.uuid}"],
    'OOD_BRAND_LINK_ACTIVE_BG_COLOR' => [:brand_link_active_bg_color, "setup-#{SecureRandom.uuid}"],
    'BOOTSTRAP_NAVBAR_DEFAULT_LINK_ACTIVE_BG' => [:brand_link_active_bg_color, "setup-#{SecureRandom.uuid}"],
    'BOOTSTRAP_NAVBAR_INVERSE_LINK_ACTIVE_BG' => [:brand_link_active_bg_color, "setup-#{SecureRandom.uuid}"],
    'OOD_NAVBAR_TYPE' => [:navbar_type, "light"],
    'OOD_PINNED_APPS_GROUP_BY' => [:pinned_apps_group_by, "setup-#{SecureRandom.uuid}"],
    'OOD_PUBLIC_URL' => [:public_url, Pathname.new("/#{SecureRandom.uuid}")],
    'OOD_ANNOUNCEMENT_PATH' => [:announcement_path, Pathname.new("/#{SecureRandom.uuid}")],

    'SHOW_ALL_APPS_LINK' => [:show_all_apps_link, true],
  }

  def setup()
    @test_temp_dir = Dir.mktmpdir
    Configuration.stubs(:user_settings_file).returns("#{@test_temp_dir}/settings.yml")
  end

  def teardown
    FileUtils.remove_entry(@test_temp_dir)
  end

  test "properties expected defaults" do
    defaults = {
      dashboard_header_img_logo: nil,
      disable_dashboard_welcome_message: false,
      disable_dashboard_logo: false,
      dashboard_logo: nil,
      dashboard_logo_height: nil,
      dashboard_layout: nil,
      pinned_apps: [],
      pinned_apps_menu_length: 6,
      profile_links: [],
      custom_css_files: [],
      custom_javascript_files: [],
      dashboard_title: "Open OnDemand",
      public_url: Pathname.new("/public"),
      announcement_path: [Pathname.new('/etc/ood/config/announcement.md'), Pathname.new('/etc/ood/config/announcement.yml'), Pathname.new('/etc/ood/config/announcements.d')],

      brand_bg_color: nil,
      brand_link_active_bg_color: nil,
      navbar_type: "dark",
      pinned_apps_group_by: nil,

      show_all_apps_link: false,
      filter_nav_categories?: false,
      nav_categories: ["Apps", "Files", "Jobs", "Clusters", "Interactive Apps"],
      nav_bar: [],
      help_bar: [],
      help_menu: [],
      interactive_apps_menu: [],
      custom_pages: {},
      support_ticket: {},
      apps_datatable: { page_length: 10 },
    }

    # ensure all properties are tested
    UserConfiguration::USER_PROPERTIES.each do |property|
      assert_equal true, defaults.key?(property.name), "ensure property #{property.name} default value is tested"
    end

    Configuration.stubs(:config).returns({ })
    with_modified_env({ }) do
      target = UserConfiguration.new
      defaults.each do |key, default_value|
        if default_value.nil?
          assert_nil target.send(key), "Default value for #{key} should have been nil"
        else
          assert_equal default_value, target.send(key), "Default value for #{key} should have been #{default_value}"
        end
      end
    end
  end

  test "inverse navbar is dark" do
    with_modified_env(OOD_NAVBAR_TYPE: 'inverse') do
      assert_equal 'dark', UserConfiguration.new.navbar_type
    end
  end

  test "dark navbar is dark" do
    with_modified_env(OOD_NAVBAR_TYPE: 'dark') do
      assert_equal 'dark', UserConfiguration.new.navbar_type
    end
  end

  test "default navbar is light" do
    with_modified_env(OOD_NAVBAR_TYPE: 'default') do
      assert_equal 'light', UserConfiguration.new.navbar_type
    end
  end

  test "light navbar is light" do
    with_modified_env(OOD_NAVBAR_TYPE: 'light') do
      assert_equal 'light', UserConfiguration.new.navbar_type
    end
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

    assert_equal pinned_apps, UserConfiguration.new.pinned_apps
  end

  test "public_url should start with a forward /." do
    Configuration.stubs(:config).returns({public_url: "https://example.com" })
    target = UserConfiguration.new

    assert_equal Pathname.new("/public"), target.public_url

    Configuration.stubs(:config).returns({public_url: "test/invalid/path" })
    target = UserConfiguration.new

    assert_equal Pathname.new("/public"), target.public_url

    Configuration.stubs(:config).returns({public_url: "/test/valid/path" })
    target = UserConfiguration.new

    assert_equal Pathname.new("/test/valid/path"), target.public_url
  end

  test "announcement_path supports string property" do
    Configuration.stubs(:config).returns({announcement_path: "/string/path" })
    target = UserConfiguration.new

    assert_equal [Pathname.new("/string/path")], target.announcement_path
  end

  test "announcement_path supports array property" do
    Configuration.stubs(:config).returns({announcement_path: ["/array/path/1", "/array/path/2"] })
    target = UserConfiguration.new

    assert_equal [Pathname.new("/array/path/1"), Pathname.new("/array/path/2")], target.announcement_path
  end

  test "filter_nav_categories? should return true when categories is set in config" do
    Configuration.stubs(:config).returns({nav_categories: []})
    assert_equal true, UserConfiguration.new.filter_nav_categories?
  end

  test "filter_nav_categories? should return false when nav_categories is nil" do
    Configuration.stubs(:config).returns({})
    assert_equal false, UserConfiguration.new.filter_nav_categories?

    Configuration.stubs(:config).returns({nav_categories: []})
    assert_equal true, UserConfiguration.new.filter_nav_categories?
  end

  test "create_service_class returns SupportTicketEmailService when email configuration object defined" do
    Configuration.stubs(:config).returns({support_ticket: {email: {}}})
    service = UserConfiguration.new.support_ticket_service
    assert_equal "SupportTicketEmailService", service.class.name
  end

  test "create_service_class returns SupportTicketRtService when rt_api configuration object defined" do
    Configuration.stubs(:config).returns({support_ticket: {rt_api: {}}})
    service = UserConfiguration.new.support_ticket_service
    assert_equal "SupportTicketRtService", service.class.name
  end

  test "create_service_class returns SupportTicketServiceNowService when servicenow_api configuration object defined" do
    Configuration.stubs(:config).returns({support_ticket: {servicenow_api: {}}})
    service = UserConfiguration.new.support_ticket_service
    assert_equal "SupportTicketServiceNowService", service.class.name
  end

  test "create_service_class throws exception when no service class configured" do
    Configuration.stubs(:config).returns({})
    assert_raise StandardError do
      UserConfiguration.new.support_ticket_service
    end
  end

  test "profile - Configuration.host_based_profiles should enforce request_hostname as profile" do
    Configuration.stubs(:config).returns({ profiles: { my_profile: {}, request_hostname_profile: {}, user_settings_profile: {} } })
    Configuration.stubs(:host_based_profiles).returns(true)
    Configuration.stubs(:default_profile).returns('my_profile')
    target = UserConfiguration.new(request_hostname: "request_hostname_profile")
    target.update_user_settings({profile: "user_settings_profile"})

    assert_equal :request_hostname_profile, target.profile
  end

  test "profile - UserSettingsStore should take precedence over other profile configurations when it is defined" do
    Configuration.stubs(:config).returns({ profiles: { my_profile: {}, request_hostname_profile: {}, user_settings_profile: {} } })
    Configuration.stubs(:default_profile).returns('my_profile')
    target = UserConfiguration.new(request_hostname: "request_hostname_profile")
    target.update_user_settings({profile: "user_settings_profile"})

    assert_equal :user_settings_profile, target.profile
  end

  test "profile - Host Based profile should take precedence over other profile configurations when it is defined and UserSettingsStore profile is not defined" do
    Configuration.stubs(:config).returns({ profiles: { my_profile: {}, request_hostname_profile: {} } })
    Configuration.stubs(:default_profile).returns('my_profile')
    target = UserConfiguration.new(request_hostname: "request_hostname_profile")
    target.update_user_settings({profile: "user_settings_profile"})

    assert_equal :request_hostname_profile, target.profile
  end

  test "profile - Default profile should be selected when it is defined in configuration and no other profiles defined" do
    Configuration.stubs(:config).returns({ profiles: { my_profile: {} } })
    Configuration.stubs(:default_profile).returns('my_profile')
    target = UserConfiguration.new(request_hostname: "request_hostname_profile")
    target.update_user_settings({profile: "user_settings_profile"})

    assert_equal :my_profile, target.profile
  end

  test "profile should return nil when no profiles are defined" do
    Configuration.stubs(:config).returns({})
    Configuration.stubs(:default_profile).returns('my_profile')
    target = UserConfiguration.new(request_hostname: "request_hostname_profile")
    target.update_user_settings({profile: "user_settings_profile"})

    assert_nil target.profile
  end

  test "profile should return nil when no profile configuration are defined" do
    Configuration.stubs(:config).returns({ profiles: { my_profile: {}, request_hostname_profile: {}, user_settings_profile: {} } })
    target = UserConfiguration.new

    assert_nil target.profile
  end

  test "fetch should use key as symbol" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new
    target.update_user_settings({profile: 'profile_test'})

    assert_equal "test_value_1", target.send(:fetch, "key_1")
    assert_equal "test_value_2", target.send(:fetch, "key_2")
  end

  test "fetch should use the profile value when profile defines a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new
    target.update_user_settings({profile: 'profile_test'})

    assert_equal "test_value_1", target.send(:fetch, :key_1)
    assert_equal "test_value_2", target.send(:fetch, :key_2)
  end

  test "fetch should use the root configuration value when profile does not define a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new

    assert_nil target.profile
    assert_equal "default_value_3", target.send(:fetch, :key_3)
  end

  test "fetch should use the default value when the profile and root configurations do not define a value" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new
    target.update_user_settings({profile: 'profile_test'})

    assert_equal "default_value_argument", target.send(:fetch, :missing_key, "default_value_argument")
  end

  test "fetch should use the profile value when is defined with nil" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new
    target.update_user_settings({profile: 'profile_test'})

    assert_nil target.send(:fetch, :key_3, "default")
  end

  test "fetch should use the root value when is defined with nil and not defined in profile" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new
    target.update_user_settings({profile: 'profile_test'})

    assert_nil target.send(:fetch, :key_4, "default")
  end

  test "fetch should handle nil keys" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new

    assert_nil target.send(:fetch, nil)
    assert_equal "default_value_argument", target.send(:fetch, nil, "default_value_argument")
  end

  test "fetch should return nil for undefined keys" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new

    assert_nil target.send(:fetch, "missing_key")
  end

  test "fetch should return objects that cannot be modified" do
    Configuration.stubs(:config).returns(DEFAULT_CONFIG)
    target = UserConfiguration.new

    result = target.send(:fetch, "key_array")

    assert_raise FrozenError do
      result.append("new_value")
    end
  end

  test 'USER_PROPERTIES should respond to env variables when read_from_environment is enabled' do
    value_in_config = "config-#{SecureRandom.uuid}"
    configuration = create_properties_configuration(value_in_config)
    Configuration.stubs(:config).returns(configuration)

    target = UserConfiguration.new
    UserConfiguration::USER_PROPERTIES.each do |property|
      next unless property.read_from_environment?

      property.environment_names.each do |env_var|
        property_value = ENVIRONMENT_PROPERTIES[env_var][1]
        value_in_env = property_value.to_s
        with_modified_env({ env_var => value_in_env }) do
          assert_equal property_value, target.send(property.name), "#{property.name} should have responded to ENV['#{env_var}']=#{ENV[env_var]}"
        end
      end

    end
  end

  test 'USER_PROPERTIES should respond to ConfigurationSingleton.config' do
    value_in_config = "config-#{SecureRandom.uuid}"
    configuration = create_properties_configuration(value_in_config)
    Configuration.stubs(:config).returns(configuration)

    target = UserConfiguration.new
    UserConfiguration::USER_PROPERTIES.each do |property|
      assert_equal value_in_config, target.send(property.name), "#{property.name} should have been #{value_in_config} through ConfigurationSingleton."
    end
  end

  test 'USER_PROPERTIES should respond to profile configuration in ConfigurationSingleton.config' do
    value_in_profile = "profile-#{SecureRandom.uuid}"
    configuration = create_properties_configuration(value_in_profile, 'strings_profile')
    Configuration.stubs(:config).returns(configuration)

    target = UserConfiguration.new
    target.update_user_settings({profile: "strings_profile"})
    UserConfiguration::USER_PROPERTIES.each do |property|
      assert_equal value_in_profile, target.send(property.name), "#{property.name} should have been #{value_in_profile} through profile strings_profile in ConfigurationSingleton"
    end
  end

  test 'env variables have precedence in USER_PROPERTIES when read_from_environment is enabled' do
    env = ENVIRONMENT_PROPERTIES.each_with_object({}) do |(env_var, property_info), hash|
      hash[env_var] = property_info[1].to_s
    end


    value_in_config = "config-#{SecureRandom.uuid}"
    configuration = create_properties_configuration(value_in_config)
    Configuration.stubs(:config).returns(configuration)

    target = UserConfiguration.new
    UserConfiguration::USER_PROPERTIES.each do |property|
      next unless property.read_from_environment?

      property.environment_names.each do |env_var|
        expected_value = ENVIRONMENT_PROPERTIES[env_var][1]
        with_modified_env({ env_var => expected_value.to_s }) do
          assert_equal expected_value, target.send(property.name), "Value for #{property.name} as environment: #{env_var} should have been #{expected_value}"
        end
      end
    end
  end

  test 'ensure all properties that can have an environment value are verified' do
    # ensure all properties are tested
    UserConfiguration::USER_PROPERTIES.each do |property|
      next unless property.read_from_environment?
      property.environment_names.each do |env_var|
        assert_equal true, ENVIRONMENT_PROPERTIES.key?(env_var), "ensure property: #{property.name} with environment key: #{env_var} is added to ENVIRONMENT_PROPERTIES"
      end
    end

    Configuration.stubs(:config).returns({ })
    target = UserConfiguration.new

    # ensure all environment variables are configure properly in the properties
    ENVIRONMENT_PROPERTIES.each do |env_var, property_info|
      property = property_info[0]
      expected_value = property_info[1]

      with_modified_env({ env_var => expected_value.to_s }) do
        assert_equal expected_value, target.send(property), "Value for #{property} as environment: #{env_var} should have been #{expected_value}"
      end
    end

  end

  private

  def create_properties_configuration(value_in_config, profile = nil)
    config = UserConfiguration::USER_PROPERTIES.each_with_object({}) do |property, hsh|
      hsh[property.name] = value_in_config
    end.deep_symbolize_keys

    return config unless profile

    { profiles: { profile.to_sym => config } }
  end

end