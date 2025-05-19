require 'test_helper'

class ConfigurationSingletonTest < ActiveSupport::TestCase
  def config_fixtures
    {
      OOD_CONFIG_D_DIRECTORY: "#{Rails.root}/test/fixtures/config/ondemand.d"
    }
  end

  def no_config_env
    {
      OOD_CONFIG_D_DIRECTORY: '/dev/null'
    }
  end

  test "should have default config root" do
    assert_equal Pathname.new("/etc/ood/config/apps/dashboard"), ConfigurationSingleton.new.config_root
  end

  test "can configure config root" do
    with_modified_env(OOD_APP_CONFIG_ROOT: '/path/to/config') do
      assert_equal Pathname.new('/path/to/config'), ConfigurationSingleton.new.config_root
    end
  end

  test "should not load external configuration by default if not production" do
    refute ConfigurationSingleton.new.load_external_config?
  end

  test "can enable external configuration if not production" do
    with_modified_env(OOD_LOAD_EXTERNAL_CONFIG: 'true') do
      assert ConfigurationSingleton.new.load_external_config?
    end
  end

  test "should load external configuration by default if production" do
    with_modified_env(RAILS_ENV: 'production') do
      assert ConfigurationSingleton.new.load_external_config?
    end
  end

  test "can disable external configuration if production" do
    with_modified_env(RAILS_ENV: 'production', OOD_LOAD_EXTERNAL_CONFIG: 'false') do
      refute ConfigurationSingleton.new.load_external_config?
    end
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

      with_modified_env(OOD_APP_CONFIG_ROOT: env.dirname.to_s, OOD_LOAD_EXTERNAL_CONFIG: 'true') do
        ConfigurationSingleton.new.load_dotenv_files
        assert_equal 'test_123', ENV['TEST_UNQUOTE']
        assert_equal 'another test', ENV['TEST_QUOTE']
        assert_equal '123', ENV['TEST_NUMBER']
        assert_nil ENV['TEST_UNDEFINED']
      end
    end
  end

  test "should load environment variable overload" do
    Dir.mktmpdir do |dir|
      with_modified_env(FOO: '123') do
        Pathname.new(dir).join('.env.overload').write <<-EOT
          FOO=456
        EOT

        cfg = ConfigurationSingleton.new
        cfg.stubs(:app_root).returns(Pathname.new(dir))
        cfg.load_dotenv_files

        assert_equal '456', ENV['FOO']
      end
    end
  end

  test "should load environment variable local overloads" do
    Dir.mktmpdir do |dir|
      environment = "test"
      with_modified_env(FOO: '123') do
        Configuration

        Pathname.new(dir).join(".env.#{environment}.overload").write <<-EOT
          FOO=456
        EOT

        Pathname.new(dir).join(".env.#{environment}.local.overload").write <<-EOT
          FOO=789
        EOT

        cfg = ConfigurationSingleton.new
        cfg.stubs(:app_root).returns(Pathname.new(dir))
        cfg.stubs(:rails_env).returns(environment)
        cfg.load_dotenv_files

        assert_equal '789', ENV['FOO']
      end
    end
  end

  test "rails_env specific env var overloads have precendent over env overloads" do
    Dir.mktmpdir do |dir|
      environment = "test"
      with_modified_env(FOO: '123') do
        Pathname.new(dir).join('.env.overload').write <<-EOT
          FOO=456
        EOT

        Pathname.new(dir).join(".env.#{environment}.overload").write <<-EOT
          FOO=789
        EOT

        cfg = ConfigurationSingleton.new
        cfg.stubs(:app_root).returns(Pathname.new(dir))
        cfg.stubs(:rails_env).returns(environment)
        cfg.load_dotenv_files

        assert_equal '789', ENV['FOO']
      end
    end
  end

  test "should have default bc config root" do
    assert_equal Pathname.new("/etc/ood/config/apps"), ConfigurationSingleton.new.bc_config_root
  end

  test "can configure bc config root" do
    with_modified_env(OOD_BC_APP_CONFIG_ROOT: '/path/to/bc_config') do
      assert_equal Pathname.new('/path/to/bc_config'), ConfigurationSingleton.new.bc_config_root
    end
  end

  test "should not load external bc configuration by default if not production" do
    refute ConfigurationSingleton.new.load_external_bc_config?
  end

  test "can enable external bc configuration if not production" do
    with_modified_env(OOD_LOAD_EXTERNAL_BC_CONFIG: 'true') do
      assert ConfigurationSingleton.new.load_external_bc_config?
    end
  end

  test "should load external bc configuration by default if production" do
    with_modified_env(RAILS_ENV: 'production') do
      assert ConfigurationSingleton.new.load_external_bc_config?
    end
  end

  test "can disable external bc configuration if production" do
    with_modified_env(RAILS_ENV: 'production', OOD_LOAD_EXTERNAL_BC_CONFIG: 'false') do
      refute ConfigurationSingleton.new.load_external_bc_config?
    end
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
    with_modified_env(OOD_APP_DEVELOPMENT: 'true') do
      assert ConfigurationSingleton.new.app_development_enabled?
    end

    with_modified_env(OOD_APP_DEVELOPMENT: 'false') do
      refute ConfigurationSingleton.new.app_development_enabled?
    end
  end

  test "should have app sharing disabled by default" do
    refute ConfigurationSingleton.new.app_sharing_enabled?
  end

  test "can configure whether app sharing is enabled or disabled" do
    with_modified_env(OOD_APP_SHARING: 'true') do
      assert ConfigurationSingleton.new.app_sharing_enabled?
    end

    with_modified_env(OOD_APP_SHARING: 'false') do
      refute ConfigurationSingleton.new.app_sharing_enabled?
    end
  end

  test "should have default developer docs url" do
    assert_equal "https://go.osu.edu/ood-app-dev", ConfigurationSingleton.new.developer_docs_url
  end

  test "can configure developer docs url" do
    with_modified_env(OOD_DASHBOARD_DEV_DOCS_URL: 'https://www.example.com') do
      assert_equal 'https://www.example.com', ConfigurationSingleton.new.developer_docs_url
    end
  end

  test "support_ticket_enabled? is false by default" do
    assert_equal false, ConfigurationSingleton.new.support_ticket_enabled?
  end

  test "support_ticket_enabled? is true when support_ticket_property is defined" do
    target = ConfigurationSingleton.new
    target.stubs(:config).returns({support_ticket: {}})

    assert_equal true, target.support_ticket_enabled?
  end

  test "support_ticket_enabled? is true when support_ticket_property is defined inside a profile" do
    target = ConfigurationSingleton.new
    target.stubs(:config).returns({profiles: {test: {support_ticket: {}}}})

    assert_equal true, target.support_ticket_enabled?
  end

  test "should have default dataroot under app if not production" do
    assert_equal Rails.root.join("data"), ConfigurationSingleton.new.dataroot
  end

  test "should have default dataroot under home dir if production" do
    with_modified_env(RAILS_ENV: 'production', OOD_DATAROOT: nil) do
      assert_equal Pathname.new('~/ondemand/data/sys/dashboard').expand_path, ConfigurationSingleton.new.dataroot
    end
  end

  test "can configure full path of dataroot" do
    with_modified_env(OOD_DATAROOT: '/path/to/dataroot') do
      assert_equal Pathname.new('/path/to/dataroot'), ConfigurationSingleton.new.dataroot
    end
  end

  test "can configure portal component of dataroot if production" do
    with_modified_env(RAILS_ENV: 'production', OOD_DATAROOT: nil, OOD_PORTAL: 'MY_PORTAL') do
      assert_equal Pathname.new('~/MY_PORTAL/data/sys/dashboard').expand_path, ConfigurationSingleton.new.dataroot
    end
  end

  test "can configure app token component of dataroot if production" do
    with_modified_env(RAILS_ENV: 'production', APP_TOKEN: 'MY/APP/TOKEN', OOD_DATAROOT: nil) do
      assert_equal Pathname.new('~/ondemand/data/MY/APP/TOKEN').expand_path, ConfigurationSingleton.new.dataroot
    end
  end

  test "default value for user_settings_file" do
    with_modified_env(OOD_PORTAL: nil) do
      assert_equal Pathname.new('~/.config/ondemand/settings.yml').expand_path.to_s, ConfigurationSingleton.new.user_settings_file
    end
  end

  test "user_settings_file uses OOD_PORTAL" do
    with_modified_env(OOD_PORTAL: 'my_portal') do
      assert_equal Pathname.new('~/.config/my_portal/settings.yml').expand_path.to_s, ConfigurationSingleton.new.user_settings_file
    end
  end

  test "quota_paths correctly parses OOD_QUOTA_PATH" do
    with_modified_env(OOD_QUOTA_PATH: '/path_a/quota.json:/path_b/quota.json') do
      assert_equal ['/path_a/quota.json', '/path_b/quota.json'], ConfigurationSingleton.new.quota_paths
    end

    with_modified_env(OOD_QUOTA_PATH: 'https://example.com/quota.json:ftp://path_b/quota.json') do
      assert_equal ['https://example.com/quota.json', 'ftp://path_b/quota.json'], ConfigurationSingleton.new.quota_paths
    end
  end

  test "balance_paths correctly parses OOD_BALANCE_PATH" do
    with_modified_env(OOD_BALANCE_PATH: '/path_a/balance.json:/path_b/balance.json') do
      assert_equal ['/path_a/balance.json', '/path_b/balance.json'], ConfigurationSingleton.new.balance_paths
    end

    with_modified_env(OOD_BALANCE_PATH: 'https://example.com/balance.json:ftp://path_b/balance.json') do
      assert_equal ['https://example.com/balance.json', 'ftp://path_b/balance.json'], ConfigurationSingleton.new.balance_paths
    end
  end

  test "can set native vnc login host" do
    with_modified_env(OOD_NATIVE_VNC_LOGIN_HOST: 'owens.osc.edu') do
      assert_equal ENV['OOD_NATIVE_VNC_LOGIN_HOST'], ConfigurationSingleton.new.native_vnc_login_host
    end
  end

  test "does not throw error when it can't read config files" do
    with_modified_env(OOD_CONFIG_FILE: "/dev/null", OOD_CONFIG_D_DIRECTORY: "/dev/null") do
      assert_equal ConfigurationSingleton.new.files_enable_shell_button, true
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

  test "supports YAML anchors and aliases" do
    with_modified_env({ OOD_CONFIG_D_DIRECTORY: "#{Rails.root}/test/fixtures/config/anchors_aliases" }) do
      cfg = ConfigurationSingleton.new.send(:config)
      assert_equal 'single_value', cfg[:single_original]
      assert_equal 'single_value', cfg[:single_with_alias]

      expect_hash = {key_one: "hash_one", key_two: "hash_two"}
      assert_equal expect_hash, cfg[:hash_original]
      assert_equal expect_hash, cfg[:hash_with_alias]
    end
  end

  test "logs read and parse errors" do
    with_modified_env(config_fixtures) do
      bad_erb_rex = /bad_erb.yml.erb because of error undefined local variable or method `wont_find_this_functon/
      bad_yml_rex = /not_good_yml.yml because of error \(<unknown>\): did not find expected '-' indicator while parsing a block collection at line 2 column 3/
      $stderr.expects(:puts).with(regexp_matches(bad_erb_rex)).at_least_once
      $stderr.expects(:puts).with(regexp_matches(bad_yml_rex)).at_least_once
      ConfigurationSingleton.new.send(:config)
    end
  end

  test "files_enable_shell_button returns true by default" do
    cfg = ConfigurationSingleton.new 
    assert_equal true, cfg.files_enable_shell_button
  end

  test "files_enable_shell_button returns false when set" do
    cfg = ConfigurationSingleton.new 
    cfg.stubs(:config).returns({files_enable_shell_button: false})
    assert_equal false, cfg.files_enable_shell_button
  end

  test 'boolean configs have correct default' do
    c = ConfigurationSingleton.new

    with_modified_env(no_config_env) do
      c.boolean_configs.take(5).each do |config, default|
        assert_equal default, c.send(config), "#{config} should have been #{default} through the default value."
      end
    end
  end

  test 'string configs have correct default' do
    c = ConfigurationSingleton.new

    with_modified_env(no_config_env) do
      c.string_configs.take(5).each do |config, default|
        if default.nil?
          # assert_equal on nil is deprecated
          assert_nil c.send(config), "#{config} should have been nil through the default value."
        else
          assert_equal default, c.send(config), "#{config} should have been #{default} through the default value."
        end
      end
    end
  end

  test 'boolean configs respond to env variables' do
    c = ConfigurationSingleton.new

    c.boolean_configs.take(5).each do |config, default|
      env_var = "OOD_#{config.upcase}"
      with_modified_env(no_config_env.merge({ env_var => (!default).to_s })) do
        assert_equal !default, c.send(config), "#{config} should have responded to ENV['#{env_var}']=#{ENV[env_var]}."
      end
    end
  end

  test 'string configs respond to env variables' do
    c = ConfigurationSingleton.new

    c.string_configs.take(5).each do |config, _|
      env_var = "OOD_#{config.upcase}"
      other_string = 'some other string that can never be a real value 2073423rnabsdf0y3b4123kbasdoifgadf'
      with_modified_env(no_config_env.merge({ env_var => other_string })) do
        assert_equal other_string, c.send(config), "#{config} should have responded to ENV['#{env_var}']=#{ENV[env_var]}."
      end
    end
  end

  test 'dynamic configs respond config files' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_CONFIG_D_DIRECTORY: dir.to_s }) do
        # write !defaults out
        other_string = 'another random string asdfn31-ndf12nadsnfsad[nf-5t2fwnasdfm'
        File.open("#{dir}/config.yml", 'w+') do |file|
          cfg = ConfigurationSingleton.new.boolean_configs.take(5).each_with_object({}) do |(config, default), hsh|
            hsh[config.to_s] = !default
          end.merge(
            ConfigurationSingleton.new.string_configs.take(5).each_with_object({}) do |(config, _), hsh|
              hsh[config.to_s] = other_string
            end
          )
          file.write(cfg.to_yaml)
        end

        c = ConfigurationSingleton.new
        c.boolean_configs.take(5).each do |config, default|
          assert_equal !default, c.send(config), "#{config} should have been #{!default} through a fixture file."
        end
        c.string_configs.take(5).each do |config, _|
          assert_equal other_string, c.send(config), "#{config} should have been #{other_string} through a fixture file."
        end
      end
    end
  end

  test 'env variables have precedence in dynamic configs' do
    other_string = 'string in env variable'
    env = ConfigurationSingleton.new.boolean_configs.take(5).map do |config, default|
      ["OOD_#{config.upcase}", default.to_s]
    end.concat(
      ConfigurationSingleton.new.string_configs.take(5).map do |config, _|
        ["OOD_#{config.upcase}", other_string]
      end
    ).compact.to_h

    with_modified_env(config_fixtures.merge(env)) do
      c = ConfigurationSingleton.new
      c.boolean_configs.take(5).each do |config, default|
        env_var = "OOD_#{config.upcase}"
        assert_equal default, c.send(config), "#{config} should have responded to ENV['#{env_var}']=#{ENV[env_var]}."
      end
      c.string_configs.take(5).each do |config, _|
        assert_equal 'string in env variable', c.send(config), "#{config} should have been 'string in env variable'."
      end
    end

    # just to be sure, let's assert the opposite with a different env
    with_modified_env(config_fixtures) do
      c = ConfigurationSingleton.new
      c.boolean_configs.take(5).each do |config, default|
        assert_equal !default, c.send(config), "#{config} should have been #{!default} through a fixture file."
      end
      c.string_configs.take(5).each do |config, _|
        assert_equal 'string from file', c.send(config), "#{config} should have been 'string from file' through a fixture file."
      end
    end
  end

  test 'config files are sorted by name' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_CONFIG_D_DIRECTORY: dir.to_s }) do
        a_config = { 'nav_categories' => ['AAA', 'BBB'] }
        z_config = { 'nav_categories' => ['YYY', 'ZZZ'] }

        File.open("#{dir}/a_config.yml", 'w+') { |f| f.write(a_config.to_yaml) }
        File.open("#{dir}/z_config.yml", 'w+') { |f| f.write(z_config.to_yaml) }

        config = ConfigurationSingleton.new.config
        nav = config.fetch(:nav_categories)

        # z_config has overwritten a_config
        assert_equal(['YYY', 'ZZZ'], nav)
      end
    end
  end

  test 'config files are sorted by name with numbers' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_CONFIG_D_DIRECTORY: dir.to_s }) do
        zero_config = { 'nav_categories' => ['AAA', 'BBB'] }
        one_config = { 'nav_categories' => ['YYY', 'ZZZ'] }

        File.open("#{dir}/00_config.yml", 'w+') { |f| f.write(zero_config.to_yaml) }
        File.open("#{dir}/01_config.yml", 'w+') { |f| f.write(one_config.to_yaml) }

        config = ConfigurationSingleton.new.config
        nav = config.fetch(:nav_categories)

        # z_config has overwritten a_config
        assert_equal(['YYY', 'ZZZ'], nav)
      end
    end
  end

  test "bc_sessions_poll_delay default value" do
    assert_equal(10_000, ConfigurationSingleton.new.bc_sessions_poll_delay)
  end

  test "bc_sessions_poll_delay reads value from environment" do
    with_modified_env('POLL_DELAY': '20000') do
      assert_equal(20_000, ConfigurationSingleton.new.bc_sessions_poll_delay)
    end
  end

  test 'bc_sessions_poll_delay reads from config' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_CONFIG_D_DIRECTORY: dir.to_s }) do
        sessions_config = { 'bc_sessions_poll_delay' => '99999' }
        File.open("#{dir}/sessions_config.yml", 'w+') { |f| f.write(sessions_config.to_yaml) }

        assert_equal(99_999, ConfigurationSingleton.new.bc_sessions_poll_delay)
      end
    end
  end

  test "bc_sessions_poll_delay minimum value is 10_000" do
    with_modified_env('POLL_DELAY': '100') do
      assert_equal(10_000, ConfigurationSingleton.new.bc_sessions_poll_delay)
    end
  end

  test "bc_sessions_poll_delay respnods to new environment variable" do
    with_modified_env('OOD_BC_SESSIONS_POLL_DELAY': '30000') do
      assert_equal(30_000, ConfigurationSingleton.new.bc_sessions_poll_delay)
    end
  end

  test "bc_sessions_poll_delay's new variable has precedence over the old" do
    with_modified_env('OOD_BC_SESSIONS_POLL_DELAY': '30000', POLL_DELAY: '40000') do
      assert_equal(30_000, ConfigurationSingleton.new.bc_sessions_poll_delay)
    end
  end

  test "rails_env_production? should return true if production environment" do
    with_modified_env(RAILS_ENV: 'production') do
      assert ConfigurationSingleton.new.rails_env_production?
    end
  end

  test "rails_env_production? should return false if development or test environment" do
    with_modified_env(RAILS_ENV: 'development') do
      refute ConfigurationSingleton.new.rails_env_production?
    end

    with_modified_env(RAILS_ENV: 'test') do
      refute ConfigurationSingleton.new.rails_env_production?
    end
  end
end
