# frozen_string_literal: true

require 'test_helper'

module MotdFormatter
  class OscTest < ActiveSupport::TestCase
    include MotdFormatter
    # test date order of example Motd file
    #
    test 'motd message date format' do
      date = Date.new(2016, 5, 4)

      # assume year month day
      msg = "2016/05/04\n--- NEW CLUSTER\n\nSomething good!"
      assert_equal date, MotdFormatterOsc::Message.from(msg).date
      msg = "2016-05-04\n--- NEW CLUSTER\n\nSomething good!"
      assert_equal date, MotdFormatterOsc::Message.from(msg).date
      msg = "2016.05.04\n--- NEW CLUSTER\n\nSomething good!"
      assert_equal date, MotdFormatterOsc::Message.from(msg).date
      msg = "2016 05 04\n--- NEW CLUSTER\n\nSomething good!"
      assert_nil MotdFormatterOsc::Message.from(msg)
      msg = "2016+05+04\n--- NEW CLUSTER\n\nSomething good!"
      assert_nil MotdFormatterOsc::Message.from(msg)
    end

    test 'test when motd formatter_osc_valid' do
      path = "#{Rails.root}/test/fixtures/files/motd_valid"
      motd_file = MotdFile.new(path)
      formatted_motd = MotdFormatterOsc.new motd_file
      expected_file = File.open(path).read

      assert_equal true, motd_file.exist?
      assert_equal path, motd_file.motd_path
      assert_equal expected_file, motd_file.content
      assert_equal 3, formatted_motd.messages.count
    end

    test 'test when motd_formatter_osc empty' do
      path = "#{Rails.root}/test/fixtures/files/motd_empty"
      motd_file = MotdFile.new(path)
      formatted_motd = MotdFormatterOsc.new motd_file

      assert_equal true, motd_file.exist?
      assert_equal path, motd_file.motd_path
      assert_equal '', motd_file.content
      assert_equal 0, formatted_motd.messages.count
    end

    test 'test when motd formatter_osc_missing' do
      path = "#{Rails.root}/test/fixtures/files/motd_missing"
      motd_file = MotdFile.new(path)
      formatted_motd = MotdFormatterOsc.new motd_file

      assert_equal false, motd_file.exist?
      assert_equal path, motd_file.motd_path
      assert_equal '', motd_file.content
      assert_equal 0, formatted_motd.messages.count
    end

    test 'test when motd formatter_osc_nil' do
      motd_file = nil
      formatted_motd = MotdFormatterOsc.new motd_file

      assert_not_nil formatted_motd.content
    end
  end
end
