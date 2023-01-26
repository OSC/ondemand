# frozen_string_literal: true

require 'test_helper'

class MotdFormatterMarkdownTest < ActiveSupport::TestCase
  include MotdFormatter
  test 'test when motd formatter_markdown_valid' do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdown.new(motd_file)
    expected_file = OodAppkit.markdown.render(motd_file.content)

    assert_equal expected_file, formatted_motd.content
  end

  test 'test when motd_formatter_markdown empty' do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdown.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test 'test when motd formatter_markdown_missing' do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterMarkdown.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test 'test when motd formatter_markdown_nil' do
    motd_file = nil
    formatted_motd = MotdFormatterMarkdown.new(motd_file)

    assert_not_nil formatted_motd.content
  end
end
