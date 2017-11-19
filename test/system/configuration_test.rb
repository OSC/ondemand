require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  #FIXME: this approach is ugly and difficult to follow
  #
  # Marshaling the AppConfig doesn't work because the methods are evaluated when
  # you call them: AppConfig doesn't store data for most of its options.
  #
  # Using Bundler.with_clean_env to provide several unit tests, one for loading
  # dotenv, and one for Configuration.new once expected env is loaded, doesn't
  # let us test dataroot because of OodAppkit's approach to storing the dataroot
  # as an instance variable.
  def runner(code, env: 'development', envvars: '')
    Tempfile.open('runnerbin') do |f|
      Bundler.with_clean_env do
        f.write(code)
        f.close
        `RAILS_ENV=#{env} #{envvars} bin/rails runner -e #{env} #{f.path}`
      end
    end
  end

  test "configuration defaults in development env" do
    assert Dir.glob(".env.local{.development,.production,}").none?, "these tests should not be run with a .env.local or .env.local.development or .env.local.production"

    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))'))

    assert_nil config.brand_bg_color
    assert_equal Rails.root.join("data").to_s, config.dataroot.to_s
    assert_equal false, config.load_external_config
  end

  test "loading custom OSC external config in production env" do
    config_root = Rails.root.join('config','examples','osc')
    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))', env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}"))

    assert_equal '#c8102e', config.brand_bg_color
    assert_equal File.expand_path("~/ondemand/data/sys/dashboard"), config.dataroot.to_s
    assert_equal true, config.load_external_config
  end

  test "loading custom AweSim external config in production env" do
    config_root = Rails.root.join('config','examples','awesim')
    config = Marshal.load(runner('puts Marshal.dump(OpenStruct.new(brand_bg_color: AppConfig.brand_bg_color, dataroot: AppConfig.dataroot, load_external_config: AppConfig.load_external_config?))', env: 'production', envvars: "OOD_APP_CONFIG_ROOT=#{config_root}"))

    assert_nil config.brand_bg_color
    assert_equal File.expand_path("~/awesim/data/sys/dashboard"), config.dataroot.to_s
    assert_equal true, config.load_external_config
  end
end
