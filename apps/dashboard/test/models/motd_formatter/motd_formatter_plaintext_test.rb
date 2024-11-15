# frozen_string_literal: true

require 'test_helper'

class MotdFormatterPlaintextTest < ActiveSupport::TestCase
  include MotdFormatter
  test 'test when motd formatter_plaintext_valid' do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintext.new(motd_file)
    expected_file = File.open(path).read

    assert_equal expected_file, formatted_motd.content
  end

  test 'test when motd_formatter_plaintext empty' do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintext.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test 'test when motd formatter_plaintext_missing' do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintext.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test 'test when motd formatter_plaintext_nil' do
    motd_file = nil
    formatted_motd = MotdFormatterPlaintext.new(motd_file)

    assert_not_nil formatted_motd.content
  end
end
