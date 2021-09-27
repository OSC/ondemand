require 'test_helper'

class AllowlistPolicyTest < ActiveSupport::TestCase

  test "permitted? should raise ArgumentError if wrong user and false if path not child of parent" do
    permitted_path = "/somebody/home/dir"
    not_subpath = "/sombody/home/../dir"
    wrong_user = "~user/some/path"

    cfg = Configuration.allowlist_paths
    cfg.stubs(:allowlist_paths).returns([permitted_path])
    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert allowlist.permitted?(permitted_path)
    refute allowlist.permitted?(not_subpath)
    assert_raise ArgumentError do 
      allowlist.permitted?(wrong_user)
    end
  end

  test "validate? should raise AllowlistPolicy::Forbidden error if not permitted by allowlist" do
    permitted_path = "/somebody/home/dir"
    non_permitted_path = "/nobody/dir/home"

    cfg = Configuration.allowlist_paths 
    cfg.stubs(:allowlist_paths).returns([permitted_path])

    allowlist = AllowlistPolicy.new(cfg.allowlist_paths)

    assert allowlist.permitted?(permitted_path)
    assert_raise AllowlistPolicy::Forbidden do
      allowlist.validate!(non_permitted_path)
    end
  end
end
