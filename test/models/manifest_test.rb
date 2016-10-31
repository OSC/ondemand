require 'test_helper'

class ManifestTest < ActiveSupport::TestCase
  test "faicon set" do
    manifest = Manifest.new("icon" => "fa://wrench")
    assert_equal "fa://wrench", manifest.icon

    assert_equal "wrench", FontAwesomeIcon.new(manifest.icon).icon
  end

  test "faicon malformed" do
    manifest = Manifest.new("icon" => "fa_wrench")
    assert_equal FontAwesomeIcon::DEFAULT, FontAwesomeIcon.new(manifest.icon).icon
  end

  test "faicon default" do
    manifest = Manifest.new({})
    assert_equal FontAwesomeIcon::DEFAULT, FontAwesomeIcon.new(manifest.icon).icon
  end
end
