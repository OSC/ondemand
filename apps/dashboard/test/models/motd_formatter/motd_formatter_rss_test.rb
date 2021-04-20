require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  include MotdFormatter
  test "test when motd formatter_rss_valid" do

    path = "#{Rails.root}/test/fixtures/files/motd_rss"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterRss.new motd_file

    assert formatted_motd.content.items.is_a? Enumerable
  end

  test "test when motd_formatter_rss invalid" do
    path = "#{Rails.root}/test/fixtures/files/motd_rss_invalid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterRss.new motd_file

    assert_nil formatted_motd.content
  end

  test "test when motd_formatter_rss empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterRss.new motd_file

    assert_nil formatted_motd.content
  end

  test "test when motd formatter_rss_missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterRss.new motd_file

    assert_nil formatted_motd.content
  end

  test "test when motd formatter_rss_nil" do
    motd_file = nil
    formatted_motd = MotdFormatterRss.new motd_file

    assert_nil formatted_motd.content
  end
end
