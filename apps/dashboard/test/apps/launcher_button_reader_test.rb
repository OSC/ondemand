require 'test_helper'

class LauncherButtonReaderTest < ActiveSupport::TestCase
  # Restore the state of ENV after each test
  def setup
    @env = ENV.to_h
    ENV.delete("OOD_DATAROOT")
    ENV["OOD_CONFIG_D_DIRECTORY"] = "#{Rails.root}/test/fixtures/launchers/ondemand.d"
    Configuration.stubs(:launchers).returns([])
    Configuration.stubs(:launchers_path).returns([])
  end

  def teardown
    ENV.clear
    ENV.update(@env)
  end

  test "LauncherButton.launchers should read system launchers from Configuration.launchers" do
    Configuration.stubs(:launchers).returns([create_launcher_hash(id: "id", app_token: "token", order: 100)])
    result = LauncherButton.launchers
    assert_equal 1, result.length
    assert_equal "id", result[0].to_h[:metadata][:id]
    assert_equal "system", result[0].to_h[:metadata][:type]
    assert_equal 100, result[0].to_h[:metadata][:order]
    assert_equal "token", result[0].to_h[:form][:token]
  end

  private
  def create_launcher_hash(id:SecureRandom.uuid.to_s, app_token:"sys/app", order:nil)
    {
      id: id,
      order: order,
      form: {
        token: app_token
      }
    }
  end

end