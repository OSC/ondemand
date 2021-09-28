require 'test_helper'

class AllowlistPolicyTest < ActiveSupport::TestCase

  test "permitted? should return true if a permitted path is passed" do
    with_modified_env({OOD_ALLOWLIST_PATH: "/somebody/home/dir"} ) do
      permitted_path = "/somebody/home/dir"
      allowlist = AllowlistPolicy.new(Configuration.allowlist_paths)
      assert allowlist.permitted?(permitted_path)
    end
  end

  test "permitted? should raise ArgumentError if wrong user is passed" do
    with_modified_env({OOD_ALLOWLIST_PATH: "/somebody/home/dir"}) do
      wrong_user = "~user/some/path"
      allowlist = AllowlistPolicy.new(Configuration.allowlist_paths)

      assert_raise ArgumentError do
        allowlist.permitted?(wrong_user)
      end
    end
  end

  test "permitted? should return false if bad input, non-subpath, or nil is passed" do
    with_modified_env({OOD_ALLOWLIST_PATH: "/somebody/home/dir"}) do
      not_subpath = "/sombody/home/../dir"
      bad_input = "123456"
      strange_char = "🐱"

      allowlist = AllowlistPolicy.new(Configuration.allowlist_paths)

      refute allowlist.permitted?(not_subpath)
      refute allowlist.permitted?(bad_input)
      refute allowlist.permitted?(strange_char)
      refute allowlist.permitted?(nil)
    end
  end

  test "validate! should raise AllowlistPolicy::Forbidden error if not permitted by allowlist" do
    with_modified_env({OOD_ALLOWLIST_PATH: "/somebody/home/dir"}) do
      non_permitted_path = "/nobody/dir/home"
      allowlist = AllowlistPolicy.new(Configuration.allowlist_paths)

      assert_raise AllowlistPolicy::Forbidden do
        allowlist.validate!(non_permitted_path)
      end
      assert_raise AllowlistPolicy::Forbidden do
        allowlist.validate!(nil)
      end
    end
  end

  test "validate! should return nil if no error or no bad input is encountered" do
    with_modified_env({OOD_ALLOWLIST_PATH: "/somebody/home/dir"}) do
      permitted_path = "/somebody/home/dir"
      allowlist = AllowlistPolicy.new(Configuration.allowlist_paths)
      assert_nil allowlist.validate!(permitted_path)
    end
  end
end
