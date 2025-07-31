# frozen_string_literal: true

require 'test_helper'

class MotdFormatterPlaintextTest < ActiveSupport::TestCase
  include MotdFormatter
  test 'test when motd formatter_plaintext_valid' do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    with_modified_env({ 'MOTD_FORMAT': "text", 'MOTD_PATH': path }) do
      expected_file = File.open(path).read

      assert_equal expected_file, MotdFile.new.formatter.content
    end
  end

  test 'test when motd_formatter_plaintext empty' do
    with_modified_env({ 'MOTD_FORMAT': "text", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_empty" }) do
      assert_equal '', MotdFile.new.formatter.content
    end
  end

  test 'test when motd formatter_plaintext_missing' do
    with_modified_env({ 'MOTD_FORMAT': "text", 'MOTD_PATH': "#{Rails.root}/test/fixtures/files/motd_missing" }) do
      assert_nil MotdFile.new.formatter
    end
  end
end
