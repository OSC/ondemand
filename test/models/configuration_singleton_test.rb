require 'test_helper'

# FIXME: move to system directory for system tests

class ConfigurationSingletonTest < ActiveSupport::TestCase
  #FIXME: this approach is ugly and difficult to follow
  #
  # Marshaling the Configuration doesn't work because the methods are evaluated when
  # you call them: Configuration doesn't store data for most of its options.
  #
  # Using Bundler.with_clean_env to provide several unit tests, one for loading
  # dotenv, and one for ConfigurationSingleton.new once expected env is loaded, doesn't
  # let us test dataroot because of OodAppkit's approach to storing the dataroot
  # as an instance variable.
  #
  # One solution to clean up the below code would be to implement a
  # ConfigurationSingleton#to_h method.
  def runner(code, env: 'development', envvars: '')
    Tempfile.open('runnerbin') do |f|
      Bundler.with_clean_env do
        f.write(code)
        f.close
        `RAILS_ENV=#{env} #{envvars} bin/rails runner -e #{env} #{f.path}`
      end
    end
  end

  # Use bin/rails runner to get values set in Configuration after initialization
  # using marshal to pass the OpenStruct between processes
  #
  # @return [OpenStruct] attrs have values set in Configuration after initialization
  def config_via_runner(env: 'development', envvars: '')
    code = %q(puts Marshal.dump(
        OpenStruct.new(
          dataroot: Configuration.dataroot,
          production_database_path: Configuration.production_database_path,
          load_external_config: Configuration.load_external_config?
        )
      )
    )
    Marshal.load(runner(code, env: env, envvars: envvars))
  end

  test "tests should not be run with .env.local* files in directory" do
    assert Dir.glob(".env.local{.development,.production,}").none?, "these tests should not be run with a .env.local or .env.local.development or .env.local.production"
  end

  test "configuration defaults in development env" do
    config = config_via_runner

    assert_equal Rails.root.join("data").to_s, config.dataroot.to_s
    assert_equal false, config.load_external_config
  end

  test "loading custom OSC external config in production env" do
    config_root = Rails.root.join('config','examples','osc')
    config = config_via_runner(env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}")

    assert_equal File.expand_path("~/ondemand/data/sys/myjobs"), config.dataroot.to_s
    assert_equal File.expand_path("~/ondemand/data/sys/myjobs/production.sqlite3"), config.production_database_path.to_s
    assert_equal true, config.load_external_config
  end

  test "loading custom AweSim external config in production env" do
    config_root = Rails.root.join('config','examples','awesim')
    config = config_via_runner(env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}")

    assert_equal File.expand_path("~/awesim/data/sys/myjobs"), config.dataroot.to_s
    assert_equal File.expand_path("~/awesim/data/sys/myjobs/production.sqlite3"), config.production_database_path.to_s
    assert_equal true, config.load_external_config
  end

  test "setting dataroot and database path" do
    Bundler.with_clean_env do
      ENV['OOD_DATAROOT'] = nil
      ENV['RAILS_ENV'] = 'production'

      # default
      assert_equal File.expand_path("~/ondemand/data/sys/myjobs"), ConfigurationSingleton.new.dataroot.to_s
      assert_equal File.expand_path("~/ondemand/data/sys/myjobs/production.sqlite3"), ConfigurationSingleton.new.production_database_path.to_s

      # set to tmp dir
      ENV['OOD_DATAROOT'] = "/tmp/myjobs"
      assert_equal "/tmp/myjobs", ConfigurationSingleton.new.dataroot.to_s
      assert_equal "/tmp/myjobs/production.sqlite3", ConfigurationSingleton.new.production_database_path.to_s

      # set seprate database path
      ENV['DATABASE_PATH'] = "/tmp/db.sqlite3"
      assert_equal "/tmp/db.sqlite3", ConfigurationSingleton.new.production_database_path.to_s
    end
  end
end
