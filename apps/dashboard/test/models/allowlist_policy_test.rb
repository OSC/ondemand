require 'test_helper'

class AllowlistPolicyTest < ActiveSupport::TestCase

  test "permitted? should return true if a permitted path is passed" do
    permitted_path = "/somebody/home/dir"

    cfg = Configuration.allowlist_paths
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert allowlist.permitted?(permitted_path)
  end

  test "permitted? should raise ArgumentError if wrong user is passed" do
    permitted_path = "/somebody/home/dir"
    wrong_user = "~user/some/path"

    cfg = Configuration.allowlist_paths
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert_raise ArgumentError do 
      allowlist.permitted?(wrong_user)
    end
  end

  test "permitted? should return false if bad input, non-subpath, or nil is passed" do
    permitted_path = "/somebody/home/dir"
    not_subpath = "/sombody/home/../dir"
    bad_input = "123456"
    strange_char = "🐱"

    cfg = Configuration.allowlist_paths
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    refute allowlist.permitted?(not_subpath)
    refute allowlist.permitted?(bad_input)
    refute allowlist.permitted?(strange_char)
    refute allowlist.permitted?(nil)
  end

  test "validate! should raise AllowlistPolicy::Forbidden error if not permitted by allowlist" do
    permitted_path = "/somebody/home/dir"
    non_permitted_path = "/nobody/dir/home"

    cfg = Configuration.allowlist_paths 
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert_raise AllowlistPolicy::Forbidden do
      allowlist.validate!(non_permitted_path)
    end
  end

  test "validate! should return nil if no error or no bad input is encountered" do
    permitted_path = "/somebody/home/dir"

    cfg = Configuration.allowlist_paths 
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert_nil allowlist.validate!(permitted_path)
  end
end
