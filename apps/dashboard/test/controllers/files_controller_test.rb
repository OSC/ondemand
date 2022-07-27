require "test_helper"

class FilesControllerTest < ActionController::TestCase

  def setup
    Configuration.stubs(:files_app_remote_files?).returns(true)
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
end
