require 'test_helper'

class ManifestTest < ActiveSupport::TestCase
  test "faicon set" do
    m = Manifest.new("icon" => "fa://wrench")
    assert_equal "fa://wrench", m.icon

    icon = m.icon_uri
    assert_equal "fa", icon.scheme
    assert_equal "wrench", icon.host
  end

  test "faicon malformed" do
    icon = Manifest.new("icon" => "fa_wrench").icon_uri
    assert_equal "fa", icon.scheme
    assert_equal "gear", icon.host
  end

  test "faicon default" do
    icon = Manifest.new({}).icon_uri
    assert_equal "fa", icon.scheme
    assert_equal "gear", icon.host
  end
end
