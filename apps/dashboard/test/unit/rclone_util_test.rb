require 'test_helper'
require 'rclone_helper'
require 'rclone_util'

class RcloneUtilTest < ActiveSupport::TestCase
  test "list_remotes handles rclone.conf and env" do
    with_rclone_conf("/") do
        assert_equal ["alias_remote", "local_remote", "missing_auth", "s3"], RcloneUtil.list_remotes
    end
  end

  test "list_remotes handles missing rclone conf" do
    with_modified_env(RCLONE_CONFIG: "/dev/null") do
        assert_equal [], RcloneUtil.list_remotes
    end
  end

  test 'missing remote or missing auth is considered invalid' do
    with_rclone_conf('/') do
      refute RcloneUtil.valid?('missing_remote')
      refute RcloneUtil.valid?('missing_auth')
      assert RcloneUtil.valid?('local_remote')
    end
  end

  test "list_remotes handles rclone.conf, env and extra rclone config" do
    with_extra_rclone_conf("/") do
        assert_equal ["alias_remote", "extra_remote", "local_remote", "missing_auth", "s3"], RcloneUtil.list_remotes
    end
  end
end
