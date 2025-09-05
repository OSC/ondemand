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
      assert_equal date, MotdFormatter::Osc::Message.from(msg).date
      msg = "2016-05-04\n--- NEW CLUSTER\n\nSomething good!"
      assert_equal date, MotdFormatter::Osc::Message.from(msg).date
      msg = "2016.05.04\n--- NEW CLUSTER\n\nSomething good!"
      assert_equal date, MotdFormatter::Osc::Message.from(msg).date
      msg = "2016 05 04\n--- NEW CLUSTER\n\nSomething good!"
      assert_nil MotdFormatter::Osc::Message.from(msg)
      msg = "2016+05+04\n--- NEW CLUSTER\n\nSomething good!"
      assert_nil MotdFormatter::Osc::Message.from(msg)
    end

    test 'test when motd formatter_osc_valid' do
      path = "#{Rails.root}/test/fixtures/files/motd_valid"
      with_modified_env({ 'MOTD_FORMAT': "osc", 'MOTD_PATH': path }) do
        motd_file = MotdFile.new
        expected_file = File.open(path).read

        assert motd_file.exist?
        assert_equal path, motd_file.motd_path
        assert_equal expected_file, motd_file.content
        assert_equal 3, motd_file.formatter.messages.count
      end
    end
    
    test 'test when motd_formatter_osc empty' do
      path = "#{Rails.root}/test/fixtures/files/motd_empty"
      with_modified_env({ 'MOTD_FORMAT': "osc", 'MOTD_PATH': path }) do
        motd_file = MotdFile.new
        
        assert_equal true, motd_file.exist?
        assert_equal path, motd_file.motd_path
        assert_equal '', motd_file.content
        assert_equal 0, motd_file.formatter.messages.count
      end
    end

    test 'test when motd formatter_osc_missing' do
      path = "#{Rails.root}/test/fixtures/files/motd_missing"
      with_modified_env({ 'MOTD_FORMAT': "osc", 'MOTD_PATH': path }) do
        motd_file = MotdFile.new

        assert_equal false, motd_file.exist?
        assert_equal path, motd_file.motd_path
        assert_equal '', motd_file.content
        assert_nil motd_file.formatter
      end
    end
  end
end
