require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  test "test when motd_formatter_markdown_erb_valid" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)
    expected_file = OodAppkit.markdown.render(motd_file.content)

    assert_equal expected_file, formatted_motd.content
  end

  test "test when motd_formatter_markdown_erb_renders_erb" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid_erb_md"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)
    expected_file = OodAppkit.markdown.render(ERB.new(motd_file.content).result)
    
    assert_equal expected_file, formatted_motd.content
  end

  test "test when motd_formatter_markdown_erb_empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "test when motd_formatter_markdown_erb_missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "test when motd_formatter_markdown_erb_nil" do
    motd_file = nil
    formatted_motd = MotdFormatterMarkdownErb.new(motd_file)

    assert_not_nil formatted_motd.content
  end
end

