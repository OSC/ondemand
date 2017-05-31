require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  # test date order of example Motd file
  #
  test "motd message date format" do

    date = Date.new(2016, 5, 4)

    # assume year month day
    msg = "2016/05/04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016-05-04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016.05.04\n--- NEW CLUSTER\n\nSomething good!"
    assert_equal date, MotdFile::Message.from(msg).date
    msg = "2016 05 04\n--- NEW CLUSTER\n\nSomething good!"
    assert_nil MotdFile::Message.from(msg)
    msg = "2016+05+04\n--- NEW CLUSTER\n\nSomething good!"
    assert_nil MotdFile::Message.from(msg)
  end

  test "test when motd valid" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_system_file
    assert_equal 3, motd_file.messages.count
  end

  test "test when motd invalid" do
    path = "#{Rails.root}/test/fixtures/files/motd_invalid"
    motd_file = MotdFile.new(path)

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_system_file
    assert_equal 0, motd_file.messages.count
  end

  test "test when motd empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_system_file
    assert_equal 0, motd_file.messages.count
  end

  test "test when motd missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)

    assert_equal false, motd_file.exist?
    assert_equal path, motd_file.motd_system_file
    assert_equal 0, motd_file.messages.count
  end

end
