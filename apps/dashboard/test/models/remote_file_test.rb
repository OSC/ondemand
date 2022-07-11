require 'test_helper'
require 'rclone_helper'

class RemoteFileTest < ActiveSupport::TestCase
  test 'mime_type raises exception for non-file' do
    assert_raises { RemoteFile.new('/dev/nulll', 'local_remote').mime_type }
  end

  test 'mime_type handles default types' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        f = File.join(dir, 'foo.txt')
        File.write(f, 'one two three')

        assert_equal 'text/plain; charset=utf-8', RemoteFile.new("/#{File.basename(f)}", 'alias_remote').mime_type
      end
    end
  end

  test 'mime_type handles svg' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        f = File.join(dir, 'foo.svg')
        FileUtils.cp(Rails.root.join('app/assets/images/OpenOnDemand_powered_by_RGB.svg').to_s, f)

        assert_equal 'image/svg+xml', RemoteFile.new("/#{File.basename(f)}", 'alias_remote').mime_type
      end
    end
  end

  test 'mime_type handles empty file' do
    # "inode/x-empty" is returned by file command on empty file
    # we want to treat this as an empty file of "text/plain"
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        f = File.join(dir, 'foo.txt')
        FileUtils.touch f

        assert_equal 'text/plain; charset=utf-8', RemoteFile.new("/#{File.basename(f)}", 'alias_remote').mime_type,
                     'should treat "inode/x-empty" as "text/plain"'
      end
    end
  end

  test 'directory? handles directories and files' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        d = File.join(dir, 'foo')
        Dir.mkdir(d)
        # Directories containing files with same name causes problems with some rclone commands, should test
        f = File.join(d, 'foo')
        FileUtils.touch(f)

        assert_equal true, RemoteFile.new("/#{File.basename(d)}", 'alias_remote').directory?
        assert_equal false, RemoteFile.new("/#{File.basename(d)}/#{File.basename(f)}", 'alias_remote').directory?
      end
    end
  end

  test "directory? handles path that doesn't exist" do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        e = assert_raises(StandardError) do
          RemoteFile.new('/somepath', 'alias_remote').directory?
        end
        assert_equal "Remote file or directory '/somepath' does not exist", e.message
      end
    end
  end
end
