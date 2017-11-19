require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  def runner(code, environment: 'development', envvars: '')
    Tempfile.open('runnerbin') do |f|
      Bundler.with_clean_env do
        f.write(code)
        f.close
        `#{envvars} bin/rails runner -e #{environment} #{f.path}`
      end
    end
  end

  # TODO: have a block
  test "configuration defaults in development env" do
    assert Dir.glob(".env.local{.development,.production,}").none?, "these tests should not be run with a .env.local or .env.local.development or .env.local.production"

    config = Marshal.load(runner %q(
require 'ood_appkit'

config =  {
  brand_bg_color: Configuration.brand_bg_color,
  app_sharing_enabled: Configuration.app_sharing_enabled?,
  app_development_enabled: Configuration.app_development_enabled?,
  load_external_config: Configuration.load_external_config?,
  initializers_root: Configuration.initializers_root.to_s,
  dataroot: OodAppkit.dataroot.to_s
}
puts Marshal.dump(config)
))

    # config.fetch raises KeyError, so we know all these were obtained from runner
    assert_nil config.fetch(:brand_bg_color)
    assert_equal false, config.fetch(:app_sharing_enabled)
    assert_equal false, config.fetch(:app_sharing_enabled)
    assert_equal Rails.root.join("data").to_s, config.fetch(:dataroot)

    assert_equal "/etc/ood/config/apps/dashboard/initializers", config.fetch(:initializers_root)
    assert_equal false, config.fetch(:load_external_config)
  end
end
