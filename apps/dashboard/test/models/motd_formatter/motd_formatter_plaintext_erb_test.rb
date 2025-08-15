require 'test_helper'

class MotdFormatter::PlaintextErbTest < ActiveSupport::TestCase
  test "plaintext-formatter-erb returns a valid motd file when given a valid motd file" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    with_modified_env({ 'MOTD_FORMAT': "text_erb", 'MOTD_PATH': path }) do
      expected_file = File.open(path).read

      assert_equal expected_file, MotdFile.new.formatter.content
    end
  end

  test "plaintext-formatter-erb returns an empty string when given an empty motd file" do
    with_modified_env({ 'MOTD_FORMAT': "text_erb", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_empty" }) do
      assert_equal '', MotdFile.new.formatter.content
    end
  end

  test "plaintext-formatter-erb throws a standard error when given an invalid motd erb file" do
    with_modified_env({ 'MOTD_FORMAT': "text_erb", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_erb_standard_error" }) do
      assert_raises(StandardError) {
        MotdFile.new.formatter
      }
    end
  end

  test "plaintext-formatter-erb returns a valid motd erb file when given a valid motd erb file" do
    with_modified_env({ 'MOTD_FORMAT': "text_erb", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_valid_erb" }) do
      expected_file = "\nWelcome to the Ohio Supercomputer Center!\n"
      
      assert_equal expected_file, MotdFile.new.formatter.content
    end
  end
  
  test "MotdFile.formatter returns nil when given a missing file" do
    with_modified_env({ 'MOTD_FORMAT': "text_erb", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_missing" }) do
      assert_nil MotdFile.new.formatter
    end
  end
end

