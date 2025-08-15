# frozen_string_literal: true

require 'test_helper'

class MotdFormatterMarkdownTest < ActiveSupport::TestCase
  test 'test when motd formatter_markdown_valid' do
    with_modified_env({ 'MOTD_FORMAT': "markdown",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_valid" }) do
      motd_file = MotdFile.new
      expected_file = File.read "#{Rails.root}/test/fixtures/files/motd_valid_html"

      assert_equal expected_file, motd_file.formatter.content
    end
  end

  test 'test when motd formatter_markdown_missing' do
    with_modified_env({ 'MOTD_FORMAT': "markdown",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_missing" }) do
      assert_nil MotdFile.new.formatter
    end
  end

  test 'test when motd_formatter_markdown empty' do
    with_modified_env({ 'MOTD_FORMAT': "markdown",'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_empty" }) do
      assert_equal '', MotdFile.new.formatter.content
    end
  end

  test 'test when motd formatter_markdown nil' do
    motd_file = nil
    formatted_motd = MotdFile.new(motd_file)

    assert_not_nil formatted_motd.content
  end
end
