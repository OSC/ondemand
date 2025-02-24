require "test_helper"

class FilesControllerTest < ActionController::TestCase

  def setup
    Configuration.stubs(:remote_files_enabled?).returns(true)
    @date1 = 2.months.ago.to_i.to_s
    @date2 = 2.weeks.ago.to_i.to_s
    @date3 = 2.days.ago.to_i.to_s
    @date4 = 2.hours.ago.to_i.to_s
    @files = [
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 }
    ]
  end

  test "empty path is parsed" do
    @controller.send(:parse_path, "", "fs")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of PosixFile, path
    assert_equal "/", path.to_s
    assert_equal "fs", @controller.instance_variable_get(:@filesystem)
  end

  test "root path is parsed" do
    @controller.send(:parse_path, "/", "fs")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of PosixFile, path
    assert_equal "/", path.to_s
    assert_equal "fs", @controller.instance_variable_get(:@filesystem)
  end

  test "posix path is parsed" do
    @controller.send(:parse_path, "/foo/bar/file.txt", "fs")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of PosixFile, path
    assert_equal "/foo/bar/file.txt", path.to_s
    assert_equal "fs", @controller.instance_variable_get(:@filesystem)
  end

  test "posix path without slash is parsed" do
    @controller.send(:parse_path, "foo/bar", "fs")
    @controller.stubs(:params).returns({ :filepath => "" })
    path = @controller.instance_variable_get(:@path)
    assert_kind_of PosixFile, path
    assert_equal "/foo/bar", path.to_s
    assert_equal "fs", @controller.instance_variable_get(:@filesystem)
  end

  test "empty remote path is parsed" do
    @controller.send(:parse_path, "", "myremote")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of RemoteFile, path
    assert_equal "/", path.path.to_s
    assert_equal "myremote", path.remote
    assert_equal "myremote", @controller.instance_variable_get(:@filesystem)
  end

  test "root remote path is parsed" do
    @controller.send(:parse_path, "/", "myremote")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of RemoteFile, path
    assert_equal "/", path.path.to_s
    assert_equal "myremote", path.remote
    assert_equal "myremote", @controller.instance_variable_get(:@filesystem)
  end

  test "remote path is parsed" do
    @controller.send(:parse_path, "/foo/bar/file.txt", "myremote")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of RemoteFile, path
    assert_equal "/foo/bar/file.txt", path.path.to_s
    assert_equal "myremote", path.remote
    assert_equal "myremote", @controller.instance_variable_get(:@filesystem)
  end

  # https://rclone.org/docs/#valid-remote-names
  test "remote path supports valid rclone remote names" do
    @controller.send(:parse_path, "/foo/bar", "my_REMOTE 1.2-")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of RemoteFile, path
    assert_equal "/foo/bar", path.path.to_s
    assert_equal "my_REMOTE 1.2-", path.remote
    assert_equal "my_REMOTE 1.2-", @controller.instance_variable_get(:@filesystem)
  end

  # FIXME: decide expected behaviour
  '''
  test "path is posix path if remote files feature is disabled" do
    Configuration.stubs(:files_app_remote_files?).returns(false)
    @controller.send(:parse_path, "/foo/bar/file.txt", "myremote")
    path = @controller.instance_variable_get(:@path)
    assert_kind_of PosixFile, path
    assert_equal "/foo/bar/file.txt", path.path.to_s
    assert_equal "myremote", @controller.instance_variable_get(:@filesystem)
  end
  '''

  # Tests for files_controller#normalized_path
  test 'normalized_path with empty path' do
    path = @controller.send(:normalized_path, '')
    assert_equal '/', path.to_s
  end

  test 'normalized_path with root path' do
    path = @controller.send(:normalized_path, '/')
    assert_equal '/', path.to_s
  end

  test 'normalized_path with posix path' do
    path = @controller.send(:normalized_path, '/foo/bar/file.txt')
    assert_equal '/foo/bar/file.txt', path.to_s
  end

  test 'normalized_path with posix path without slash' do
    path = @controller.send(:normalized_path, 'foo/bar')
    assert_equal '/foo/bar', path.to_s
  end

  # Tests for DirectoryUtilsConcern#validate_path!
  test 'validate_path! raises error when remote_type is nil' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns(nil)
    remote_path.stubs(:remote).returns('nonexistent_remote')
    @controller.instance_variable_set(:@path, remote_path)

    error = assert_raises(StandardError) { @controller.send(:validate_path!) }
    assert_equal 'Remote nonexistent_remote does not exist', error.message
  end

  test 'validate_path! raises error when allowlist_paths is present and remote_type is local' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('local')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns(['/some/path'])

    error = assert_raises(StandardError) { @controller.send(:validate_path!) }
    assert_equal 'Remotes of type local are not allowed due to ALLOWLIST_PATH', error.message
  end

  test 'validate_path! raises error when allowlist_paths is present and remote_type is alias' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('alias')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns(['/some/path'])

    error = assert_raises(StandardError) { @controller.send(:validate_path!) }
    assert_equal 'Remotes of type alias are not allowed due to ALLOWLIST_PATH', error.message
  end

  test 'validate_path! passes when allowlist_paths is not present and remote_type is acceptable' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('sshfs')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns([])

    assert_nothing_raised { @controller.send(:validate_path!) }
  end

  # Tests for DirectoryUtilsConcern#posix_file?
  test 'posix_file? returns true when @path is a PosixFile' do
    path = PosixFile.new('/some/path')
    @controller.instance_variable_set(:@path, path)
    assert @controller.send(:posix_file?)
  end

  test 'posix_file? returns false when @path is a RemoteFile' do
    path = RemoteFile.new('/some/path', 'remote_fs')
    @controller.instance_variable_set(:@path, path)
    refute @controller.send(:posix_file?)
  end
end
