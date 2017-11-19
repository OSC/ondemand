require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  def runner(code, env: 'development', envvars: '')
    Tempfile.open('runnerbin') do |f|
      Bundler.with_clean_env do
        f.write(code)
        f.close
        `#{envvars} bin/rails runner -e #{env} #{f.path}`
      end
    end
  end

  def config_from_runner(env: 'development', envvars: '')
    Marshal.load(runner('puts Marshal.dump(AppConfig)', env: env, envvars: envvars ))
  end

  # TODO: have a block
  test "configuration defaults in development env" do
    assert Dir.glob(".env.local{.development,.production,}").none?, "these tests should not be run with a .env.local or .env.local.development or .env.local.production"

    config = config_from_runner

    assert_nil config.brand_bg_color
    assert_equal false, config.app_sharing_enabled?

    assert_equal Rails.root.join("data").to_s, config.dataroot.to_s

    assert_equal "/etc/ood/config/apps/dashboard/initializers", config.initializers_root.to_s
    assert_equal false, config.load_external_config?
  end
end
