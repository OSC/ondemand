require 'test_helper'
require 'securerandom'

class LauncherButtonTest < ActiveSupport::TestCase

  def setup
    @cluster_mock = mock("cluster")
    @cluster_mock.stubs(:id).returns("mock_cluster_id")

    @link_mock = mock("link")
    @link_mock.stubs(:icon_uri).returns("mock_icon_uri")


    @app_mock = mock("app")
    @app_mock.stubs(:clusters).returns([@cluster_mock])
    @app_mock.stubs(:link).returns(@link_mock)
  end



  test "should throw exception when token is not provided" do
    assert_raises(ArgumentError) { create_launcher(app_token:nil) }
  end

  test "should throw exception when id is not provided" do
    assert_raises(ArgumentError) { create_launcher(id:nil) }
  end

  test "should throw exception when id is not valid" do
    assert_raises(ArgumentError) { create_launcher(id:"id with spaces") }

    assert_raises(ArgumentError) { create_launcher(id:"id$%with/()") }

    assert_raises(ArgumentError) { create_launcher(id:"id@with.com") }
  end

  test "Implements <=> to order by order field with nulls last" do
    launchers = [create_launcher(id:"id_null_order", order:nil), create_launcher(id:"id_1", order:100), create_launcher(id:"id_2", order:-100), create_launcher(id:"id_3", order:0)]
    result = launchers.sort
    assert_equal "id_2", result[0].id
    assert_equal "id_3", result[1].id
    assert_equal "id_1", result[2].id
    assert_equal "id_null_order", result[3].id
  end

  test "status should default to active" do
    under_test = create_launcher
    assert_equal "active", under_test.to_h[:metadata][:status]
  end

  test "cluster should be populated from BatchConnect app clusters id" do
    BatchConnect::App.stubs(:from_token).returns(@app_mock)
    under_test = create_launcher
    assert_equal "mock_cluster_id", under_test.to_h[:form][:cluster]
  end

  test "default_logo should be populated from BatchConnect app icon uri" do
    BatchConnect::App.stubs(:from_token).returns(@app_mock)
    under_test = create_launcher
    assert_equal "mock_icon_uri", under_test.to_h[:view][:default_logo]
  end

  test "operational? should be true if token is valid" do
    BatchConnect::App.stubs(:from_token).returns(@app_mock)
    under_test = create_launcher
    assert_equal true, under_test.operational?
  end

  test "operational? should be false if token is invalid" do
    under_test = create_launcher(app_token:"invalid/app")
    assert_equal false, under_test.operational?
  end

  test "order method should return configured order" do
    under_test = create_launcher(order:100)
    assert_equal 100, under_test.order
  end

  test "id method should return configured id" do
    under_test = create_launcher(id:"set_id")
    assert_equal "set_id", under_test.id
  end

  test "to_h should return hash representation of launcher" do
    under_test = create_launcher(id:"some_id", app_token:"sys/token", order:100).to_h
    assert_equal "some_id", under_test[:metadata][:id]
    assert_equal "system", under_test[:metadata][:type]
    assert_equal 100, under_test[:metadata][:order]
    assert_equal "sys/token", under_test[:form][:token]
  end

  private

  def create_launcher(id:SecureRandom.uuid.to_s, app_token:"sys/app", order:nil)
    config = {
      id: id,
      order: order,
      form: {
        token: app_token
      }
    }

    metadata = {
      type: "system"
    }

    LauncherButton.new(metadata, config)
  end

end