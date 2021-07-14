require 'test_helper'

class FilesTest < ActiveSupport::TestCase
  test "mime_type raises exception for non-file" do
    assert_raises { Files.mime_type("/dev/nulll") }
  end

  test "mime_type handles default types" do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.txt')
      File.write(f, "one two three")

      assert_equal "text/plain", Files.mime_type(f)
    end
  end

  test "mime_type handles png" do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.svg')
      FileUtils.cp(Rails.root.join('app/assets/images/OpenOnDemand_powered_by_RGB.svg').to_s, f)

      assert_equal "image/svg+xml", Files.mime_type(f)
    end
  end

  test "mime_type handles empty file" do
    # "inode/x-empty" is returned by file command on empty file
    # we want to treat this as an empty file of "text/plain"
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.txt')
      FileUtils.touch f

      assert_equal "text/plain", Files.mime_type(f), 'should treat "inode/x-empty" as "text/plain"'
    end
  end

  test "can_download_as_zip handles erroneous output from du" do
    Dir.mktmpdir do |dir|
      path = Pathname.new(dir)
      Open3.stubs(:capture3).returns(["blarg \n 28d", "", exit_success])

      assert_equal [false, I18n.t('dashboard.files_directory_download_size_0', cmd: "timeout 10s du -cbs #{path}")], Files.can_download_as_zip?(dir)  
    end 
  end

  test "can_download_as_zip handles files sizes of 0" do
    Dir.mktmpdir do |dir|
      path = Pathname.new(dir)
      Open3.stubs(:capture3).returns(["0 /dev
        0 total", "", exit_success])

      assert_equal [false, I18n.t('dashboard.files_directory_download_size_0', cmd: "timeout 10s du -cbs #{path}")], Files.can_download_as_zip?(dir)  
    end 
  end

  test "Ensuring Files.username(uid) returns string" do
    assert_equal "9999999", Files.username(9999999)
  end
end