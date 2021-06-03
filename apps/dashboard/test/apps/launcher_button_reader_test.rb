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

  test "LauncherButton.launchers should read external launchers from Configuration.launchers_path" do
    Configuration.stubs(:launchers_path).returns(["#{Rails.root}/test/fixtures/launchers/config01"])
    result = LauncherButton.launchers
    assert_equal 1, result.length
    assert_equal "rstudio", result[0].to_h[:metadata][:id]
    assert_equal "external", result[0].to_h[:metadata][:type]
    assert_equal 20, result[0].to_h[:metadata][:order]
    assert_equal "sys/Rstudio", result[0].to_h[:form][:token]
  end

  test "LauncherButton.launchers should read external launchers nested under launchers top level field" do
    Configuration.stubs(:launchers_path).returns(["#{Rails.root}/test/fixtures/launchers/config02"])
    result = LauncherButton.launchers
    assert_equal 1, result.length
    assert_equal "nested", result[0].to_h[:metadata][:id]
    assert_equal "external", result[0].to_h[:metadata][:type]
    assert_equal 50, result[0].to_h[:metadata][:order]
    assert_equal "sys/nested", result[0].to_h[:form][:token]
  end

  test "LauncherButton.launchers should merge system launchers with external launchers and sort them by order field" do
    Configuration.stubs(:launchers_path).returns(["#{Rails.root}/test/fixtures/launchers/config01"])
    Configuration.stubs(:launchers).returns([create_launcher_hash(id: "system_id", app_token: "system_token", order: 40)])
    result = LauncherButton.launchers
    assert_equal 2, result.length

    assert_equal "rstudio", result[0].to_h[:metadata][:id]
    assert_equal "external", result[0].to_h[:metadata][:type]
    assert_equal 20, result[0].to_h[:metadata][:order]
    assert_equal "sys/Rstudio", result[0].to_h[:form][:token]

    assert_equal "system_id", result[1].to_h[:metadata][:id]
    assert_equal "system", result[1].to_h[:metadata][:type]
    assert_equal 40, result[1].to_h[:metadata][:order]
    assert_equal "system_token", result[1].to_h[:form][:token]
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