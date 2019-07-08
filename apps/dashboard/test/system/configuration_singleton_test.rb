require 'test_helper'

class ConfigurationSingletonTest < ActiveSupport::TestCase
  # Restore the state of ENV after each test
  def setup
    @env = ENV.to_h
    ENV.delete("OOD_DATAROOT")
  end

  def teardown
    ENV.clear
    ENV.update(@env)
  end

  test "should have default config root" do
    assert_equal Pathname.new("/etc/ood/config/apps/dashboard"), ConfigurationSingleton.new.config_root
  end

  test "can configure config root" do
    ENV["OOD_APP_CONFIG_ROOT"] = "/path/to/config"
    assert_equal Pathname.new("/path/to/config"), ConfigurationSingleton.new.config_root
  end

  test "should not load external configuration by default if not production" do
    refute ConfigurationSingleton.new.load_external_config?
  end

  test "can enable external configuration if not production" do
    ENV["OOD_LOAD_EXTERNAL_CONFIG"] = "true"
    assert ConfigurationSingleton.new.load_external_config?
  end

  test "should load external configuration by default if production" do
    ENV["RAILS_ENV"] = "production"
    assert ConfigurationSingleton.new.load_external_config?
  end

  test "can disable external configuration if production" do
    ENV["RAILS_ENV"] = "production"
    ENV["OOD_LOAD_EXTERNAL_CONFIG"] = "false"
    refute ConfigurationSingleton.new.load_external_config?
  end

  test "should load environment variables" do
    Dir.mktmpdir do |dir|
      env = Pathname.new(dir).join("env")
      File.open env, "w" do |f|
        f.write <<-EOT
          TEST_UNQUOTE=test_123
          TEST_QUOTE="another test"
          TEST_NUMBER=123
        EOT
      end

      ENV["OOD_APP_CONFIG_ROOT"] = env.dirname.to_s
      ENV["OOD_LOAD_EXTERNAL_CONFIG"] = "true"
      ConfigurationSingleton.new.load_dotenv_files
      assert_equal "test_123", ENV["TEST_UNQUOTE"]
      assert_equal "another test", ENV["TEST_QUOTE"]
      assert_equal "123", ENV["TEST_NUMBER"]
      assert_nil ENV["TEST_UNDEFINED"]
    end
  end

  test "should have default bc config root" do
    assert_equal Pathname.new("/etc/ood/config/apps"), ConfigurationSingleton.new.bc_config_root
  end

  test "can configure bc config root" do
    ENV["OOD_BC_APP_CONFIG_ROOT"] = "/path/to/bc_config"
    assert_equal Pathname.new("/path/to/bc_config"), ConfigurationSingleton.new.bc_config_root
  end

  test "should not load external bc configuration by default if not production" do
    refute ConfigurationSingleton.new.load_external_bc_config?
  end

  test "can enable external bc configuration if not production" do
    ENV["OOD_LOAD_EXTERNAL_BC_CONFIG"] = "true"
    assert ConfigurationSingleton.new.load_external_bc_config?
  end

  test "should load external bc configuration by default if production" do
    ENV["RAILS_ENV"] = "production"
    assert ConfigurationSingleton.new.load_external_bc_config?
  end

  test "can disable external bc configuration if production" do
    ENV["RAILS_ENV"] = "production"
    ENV["OOD_LOAD_EXTERNAL_BC_CONFIG"] = "false"
    refute ConfigurationSingleton.new.load_external_bc_config?
  end

  test "should have app development disabled by default if sandbox does not exist" do
    Dir.mktmpdir do |dir|
      sandbox = Pathname.new(dir)
      DevRouter.stubs(:base_path).returns(sandbox)
    end
    refute ConfigurationSingleton.new.app_development_enabled?
  end

  test "should have app development enabled by default if sandbox exists" do
    Dir.mktmpdir do |dir|
      sandbox = Pathname.new(dir)
      DevRouter.stubs(:base_path).returns(sandbox)
      assert ConfigurationSingleton.new.app_development_enabled?
    end
  end

  test "can configure whether app development is enabled or disabled" do
    ENV["OOD_APP_DEVELOPMENT"] = "true"
    assert ConfigurationSingleton.new.app_development_enabled?

    ENV["OOD_APP_DEVELOPMENT"] = "false"
    refute ConfigurationSingleton.new.app_development_enabled?
  end

  test "should have app sharing disabled by default" do
    refute ConfigurationSingleton.new.app_sharing_enabled?
  end

  test "can configure whether app sharing is enabled or disabled" do
    ENV["OOD_APP_SHARING"] = "true"
    assert ConfigurationSingleton.new.app_sharing_enabled?

    ENV["OOD_APP_SHARING"] = "false"
    refute ConfigurationSingleton.new.app_sharing_enabled?
  end

  test "should have default announcement paths" do
    assert_equal(
      [
        Pathname.new("/etc/ood/config/announcement.md"),
        Pathname.new("/etc/ood/config/announcement.yml"),
        Pathname.new("/etc/ood/config/announcements.d")
      ],
      ConfigurationSingleton.new.announcement_path
    )
  end

  test "can configure announcement path" do
    ENV["OOD_ANNOUNCEMENT_PATH"] = "/path/to/announcement"
    assert_equal Pathname.new("/path/to/announcement"), ConfigurationSingleton.new.announcement_path
  end

  test "should have default developer docs url" do
    assert_equal "https://go.osu.edu/ood-app-dev", ConfigurationSingleton.new.developer_docs_url
  end

  test "can configure developer docs url" do
    ENV["OOD_DASHBOARD_DEV_DOCS_URL"] = "https://www.example.com"
    assert_equal "https://www.example.com", ConfigurationSingleton.new.developer_docs_url
  end

  test "should not have default brand bg color" do
    assert_nil ConfigurationSingleton.new.brand_bg_color
  end

  test "can configure brand bg color" do
    ENV["OOD_BRAND_BG_COLOR"] = "MY_COLOR"
    assert_equal "MY_COLOR", ConfigurationSingleton.new.brand_bg_color
  end

  test "should not have default brand link active bg color" do
    assert_nil ConfigurationSingleton.new.brand_link_active_bg_color
  end

  test "can configure brand link active bg color" do
    ENV["OOD_BRAND_LINK_ACTIVE_BG_COLOR"] = "MY_COLOR"
    assert_equal "MY_COLOR", ConfigurationSingleton.new.brand_link_active_bg_color
  end

  test "should not have default logo img" do
    assert_nil ConfigurationSingleton.new.logo_img
  end

  test "can configure logo img" do
    ENV["OOD_DASHBOARD_LOGO"] = "MY_LOGO"
    assert_equal "MY_LOGO", ConfigurationSingleton.new.logo_img
  end

  test "should try to display logo img by default" do
    assert ConfigurationSingleton.new.logo_img?
  end

  test "can disable the display of logo img" do
    ENV["DISABLE_DASHBOARD_LOGO"] = "true"
    refute ConfigurationSingleton.new.logo_img?
  end

  test "should hide the all apps link by default" do
    refute ConfigurationSingleton.new.show_all_apps_link?
  end

  test "can enable the all apps link" do
    ENV["SHOW_ALL_APPS_LINK"] = "true"
    assert ConfigurationSingleton.new.show_all_apps_link?
  end

  test "should have default dataroot under app if not production" do
    assert_equal Rails.root.join("data"), ConfigurationSingleton.new.dataroot
  end

  test "should have default dataroot under home dir if production" do
    ENV["RAILS_ENV"] = "production"
    assert_equal Pathname.new("~/ondemand/data/sys/dashboard").expand_path, ConfigurationSingleton.new.dataroot
  end

  test "can configure full path of dataroot" do
    ENV["OOD_DATAROOT"] = "/path/to/dataroot"
    assert_equal Pathname.new("/path/to/dataroot"), ConfigurationSingleton.new.dataroot
  end

  test "can configure portal component of dataroot if production" do
    ENV["RAILS_ENV"] = "production"
    ENV["OOD_PORTAL"] = "MY_PORTAL"
    assert_equal Pathname.new("~/MY_PORTAL/data/sys/dashboard").expand_path, ConfigurationSingleton.new.dataroot
  end

  test "can configure app token component of dataroot if production" do
    ENV["RAILS_ENV"] = "production"
    ENV["APP_TOKEN"] = "MY/APP/TOKEN"
    assert_equal Pathname.new("~/ondemand/data/MY/APP/TOKEN").expand_path, ConfigurationSingleton.new.dataroot
  end

  test "quota_paths correctly parses OOD_QUOTA_PATH" do
    ENV["OOD_QUOTA_PATH"] = "/path_a/quota.json:/path_b/quota.json"
    assert_equal ["/path_a/quota.json", "/path_b/quota.json"], ConfigurationSingleton.new.quota_paths

    ENV["OOD_QUOTA_PATH"] = "https://example.com/quota.json:ftp://path_b/quota.json"
    assert_equal ["https://example.com/quota.json", "ftp://path_b/quota.json"], ConfigurationSingleton.new.quota_paths
  end
end
