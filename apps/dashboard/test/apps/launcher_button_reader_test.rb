require 'test_helper'

class LauncherButtonReaderTest < ActiveSupport::TestCase

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