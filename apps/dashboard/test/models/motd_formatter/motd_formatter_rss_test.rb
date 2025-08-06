require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  include MotdFormatter
  test "test when motd formatter_rss_valid" do
    with_modified_env({ 'MOTD_FORMAT': "rss", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_rss" }) do
      assert MotdFile.new.formatter.content.items.is_a? Enumerable
    end
  end

  test "test when motd_formatter_rss invalid" do
    with_modified_env({ 'MOTD_FORMAT': "rss", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_rss_invalid" }) do
      assert_nil MotdFile.new.formatter.content
    end
  end

  test "test when motd_formatter_rss empty" do
    with_modified_env({ 'MOTD_FORMAT': "rss", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_empty" }) do
      assert_nil MotdFile.new.formatter.content
    end
  end

  test "test when motd formatter_rss_missing" do
    with_modified_env({ 'MOTD_FORMAT': "rss", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_missing" }) do
      assert_nil MotdFile.new.formatter
    end
  end
end
