require 'test_helper'
require 'rclone_helper'
require 'rclone_util'

class RcloneUtilTest < ActiveSupport::TestCase
  test "list_remotes handles rclone.conf and env" do
    with_rclone_conf("/") do
        assert_equal ["alias_remote", "local_remote", "s3"], RcloneUtil.list_remotes
    end
  end

  test "list_remotes handles missing rclone conf" do
    with_modified_env(RCLONE_CONFIG: "/dev/null") do
        assert_equal [], RcloneUtil.list_remotes
    end
  end
end
