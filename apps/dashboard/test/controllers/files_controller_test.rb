require "test_helper"

class FilesControllerTest < ActionController::TestCase
  test "empty path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "" })
    path = @controller.send(:parse_path)
    assert_kind_of PosixFile, path
    assert_equal "/", path.to_s
  end

  test "root path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "/" })
    path = @controller.send(:parse_path)
    assert_kind_of PosixFile, path
    assert_equal "/", path.to_s
  end

  test "posix path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "/foo/bar/file.txt" })
    path = @controller.send(:parse_path)
    assert_kind_of PosixFile, path
    assert_equal "/foo/bar/file.txt", path.to_s
  end

  test "posix path without slash is parsed" do
    @controller.stubs(:params).returns({ :filepath => "foo/bar" })
    path = @controller.send(:parse_path)
    assert_kind_of PosixFile, path
    assert_equal "/foo/bar", path.to_s
  end

  test "path beginning with slash is posix path" do
    @controller.stubs(:params).returns({ :filepath => "/notaremote:/foo/bar" })
    path = @controller.send(:parse_path)
    assert_kind_of PosixFile, path
    assert_equal "/notaremote:/foo/bar", path.to_s
  end

  test "empty remote path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "myremote:" })
    path = @controller.send(:parse_path)
    assert_kind_of RemoteFile, path
    assert_equal "/", path.path.to_s
    assert_equal "myremote", path.remote
  end

  test "root remote path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "myremote:/" })
    path = @controller.send(:parse_path)
    assert_kind_of RemoteFile, path
    assert_equal "/", path.path.to_s
    assert_equal "myremote", path.remote
  end

  test "remote path is parsed" do
    @controller.stubs(:params).returns({ :filepath => "myremote:/foo/bar/file.txt" })
    path = @controller.send(:parse_path)
    assert_kind_of RemoteFile, path
    assert_equal "/foo/bar/file.txt", path.path.to_s
    assert_equal "myremote", path.remote
  end

  # https://rclone.org/docs/#valid-remote-names
  test "remote path supports valid rclone remote names" do
    @controller.stubs(:params).returns({ :filepath => "my_REMOTE 1.2-:/foo/bar" })
    path = @controller.send(:parse_path)
    assert_kind_of RemoteFile, path
    assert_equal "/foo/bar", path.path.to_s
    assert_equal "my_REMOTE 1.2-", path.remote
  end
end
