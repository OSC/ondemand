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

  def config_fixtures
    {
      OOD_CONFIG_D_DIRECTORY: "#{Rails.root}/test/fixtures/config/ondemand.d"
    }
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

  test "should load environment variable overload" do
    Dir.mktmpdir do |dir|
      ENV['FOO'] = '123'

      Pathname.new(dir).join(".env.overload").write <<-EOT
        FOO=456
      EOT

      cfg = ConfigurationSingleton.new
      cfg.stubs(:app_root).returns(Pathname.new(dir))
      cfg.load_dotenv_files

      assert_equal "456", ENV['FOO']
    end
  end

  test "should load environment variable local overloads" do
    Dir.mktmpdir do |dir|
      ENV['FOO'] = '123'

      Configuration

      Pathname.new(dir).join(".env.#{Rails.env}.overload").write <<-EOT
        FOO=456
      EOT

      Pathname.new(dir).join(".env.#{Rails.env}.local.overload").write <<-EOT
        FOO=789
      EOT

      cfg = ConfigurationSingleton.new
      cfg.stubs(:app_root).returns(Pathname.new(dir))
      cfg.load_dotenv_files

      assert_equal "789", ENV['FOO']
    end
  end

  test "rails_env specific env var overloads have precendent over env overloads" do
    Dir.mktmpdir do |dir|
      ENV['FOO'] = '123'

      Pathname.new(dir).join(".env.overload").write <<-EOT
        FOO=456
      EOT

      Pathname.new(dir).join(".env.#{Rails.env}.overload").write <<-EOT
        FOO=789
      EOT

      cfg = ConfigurationSingleton.new
      cfg.stubs(:app_root).returns(Pathname.new(dir))
      cfg.load_dotenv_files

      assert_equal "789", ENV['FOO']
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

  test "balance_paths correctly parses OOD_BALANCE_PATH" do
    ENV["OOD_BALANCE_PATH"] = "/path_a/balance.json:/path_b/balance.json"
    assert_equal ["/path_a/balance.json", "/path_b/balance.json"], ConfigurationSingleton.new.balance_paths

    ENV["OOD_BALANCE_PATH"] = "https://example.com/balance.json:ftp://path_b/balance.json"
    assert_equal ["https://example.com/balance.json", "ftp://path_b/balance.json"], ConfigurationSingleton.new.balance_paths
  end

  test "can set native vnc login host" do
    ENV["OOD_NATIVE_VNC_LOGIN_HOST"] = "owens.osc.edu"
    assert_equal ENV["OOD_NATIVE_VNC_LOGIN_HOST"], ConfigurationSingleton.new.native_vnc_login_host
  end

  test "reads pinned apps from config files" do
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

    with_modified_env(config_fixtures) do
      assert_equal pinned_apps, ConfigurationSingleton.new.pinned_apps
    end
  end

  test "does not throw error when it can't read config files" do
    with_modified_env(OOD_CONFIG_FILE: "/dev/null", OOD_CONFIG_D_DIRECTORY: "/dev/null") do
      assert_equal ConfigurationSingleton.new.pinned_apps, []
      assert_equal ConfigurationSingleton.new.send(:config), {}
    end
  end

  test "does not read .bak files" do
    with_modified_env(config_fixtures) do
      cfg = ConfigurationSingleton.new.send(:config)
      assert_nil cfg[:key_in_bak_file]
    end
  end

  test "reads yaml with an a files" do
    with_modified_env(config_fixtures) do
      cfg = ConfigurationSingleton.new.send(:config)
      assert_equal 'I got read!', cfg[:key_from_yaml_file]
    end
  end

  test "reads arbitrary keys" do
    with_modified_env(config_fixtures) do
      cfg = ConfigurationSingleton.new.send(:config)
      assert_equal 'test_value', cfg[:test_key]
      assert_equal ['one', 'two', 'three'], cfg[:test_array]
      assert_equal 'some_value', cfg[:test_hash][:some_key]
      assert_equal ['four', 'five', 'six'], cfg[:test_hash][:another_array]
    end
  end

  test "reads from good erb file" do
    with_modified_env(config_fixtures) do
      cfg = ConfigurationSingleton.new.send(:config)
      assert_equal 42, cfg[:the_erb_answer]
    end
  end

  test "logs read and parse errors" do
    with_modified_env(config_fixtures) do
      bad_erb_rex = /bad_erb.yml.erb because of error undefined local variable or method `wont_find_this_functon/
      bad_yml_rex = /not_good_yml.yml because of error \(<unknown>\): did not find expected '-' indicator while parsing a block collection at line 2 column 3/
      Rails.logger.expects(:error).with(regexp_matches(bad_erb_rex)).at_least_once
      Rails.logger.expects(:error).with(regexp_matches(bad_yml_rex)).at_least_once
      ConfigurationSingleton.new.send(:config)
    end
  end

  test "pinned_apps_group_by returns original category when configured with category" do
    cfg = ConfigurationSingleton.new
    cfg.stubs(:config).returns({pinned_apps_group_by: "category"})
    assert_equal "original_category", cfg.pinned_apps_group_by
  end

  test "pinned_apps_group_by returns original subcategory when configured with subcategory" do
    cfg = ConfigurationSingleton.new
    cfg.stubs(:config).returns({pinned_apps_group_by: "subcategory"})
    assert_equal "original_subcategory", cfg.pinned_apps_group_by
  end

  test "pinned_apps_group_by returns an empty string by default" do
    cfg = ConfigurationSingleton.new
    cfg.stubs(:config).returns({})
    assert_equal "", cfg.pinned_apps_group_by
  end

  test "api is disabled by default" do
    env = {
      OOD_BATCH_CONNECT_API_ENABLED: nil
    }
    with_modified_env(env) do
      refute ConfigurationSingleton.new.batch_connect_api_enabled?
    end
  end

  test "api can be enabled with environment variable" do
    env = {
      OOD_BATCH_CONNECT_API_ENABLED: "true"
    }
    with_modified_env(env) do
      assert ConfigurationSingleton.new.batch_connect_api_enabled?
    end
  end
end
