require 'test_helper'

class MotdTest < ActiveSupport::TestCase

  test "test when motd valid" do

    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    expected_file = File.open(path).read

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal expected_file, motd_file.content
  end

  test "test when motd empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal '', motd_file.content
  end

  test "test when motd missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)

    assert_equal false, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal '', motd_file.content
  end

  test "test when motd nil" do

    motd_file = MotdFile.new(nil)

    assert_equal false, motd_file.exist?
    assert_nil motd_file.motd_path
    assert_equal '', motd_file.content
  end

end
