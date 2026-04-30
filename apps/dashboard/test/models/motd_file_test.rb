require 'test_helper'

class MotdFileTest < ActiveSupport::TestCase

  test "test when motd file_valid" do

    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    expected_file = File.open(path).read

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal expected_file, motd_file.content
  end

  test "test when motd file_empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)

    assert_equal true, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal '', motd_file.content
  end

  test "test when motd file_missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)

    assert_equal false, motd_file.exist?
    assert_equal path, motd_file.motd_path
    assert_equal '', motd_file.content
  end

  test "test when motd file_nil" do

    motd_file = MotdFile.new(nil)

    assert_equal false, motd_file.exist?
    assert_nil motd_file.motd_path
    assert_equal '', motd_file.content
  end

  test 'when MOTD_PATH is unset, a default formatter is returned' do
    with_modified_env({ 'MOTD_PATH' => nil }) do
      formatter = MotdFile.new.formatter
      assert_instance_of(MotdFormatter::Default, formatter)
      assert_equal(I18n.t('dashboard.motd_title'), formatter.title)
      assert_not_empty(formatter.content.to_s)
    end
  end

  test 'when MOTD_PATH is explicitly blank, no formatter is returned' do
    with_modified_env({ 'MOTD_PATH' => '' }) do
      formatter = MotdFile.new.formatter
      assert_nil(formatter)
    end
  end
  
  test 'when rss is a remote source' do
    with_modified_env({ MOTD_PATH: 'https://www.osc.edu/rss.xml', MOTD_FORMAT: 'rss' }) do
      formatter = MotdFile.new.formatter
      assert_not_nil(formatter.title)
      assert_not_nil(formatter.content)
      assert_not_nil(formatter.content.items)
    end
  end

end
