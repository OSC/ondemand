# helper functions for tests that use rclone/remote files in files app

class ActiveSupport::TestCase

  # Avoid using local remote directly to detect cases where the path is valid on both the remote
  # and posix file system
  def remote_files_conf(root_dir)
    {
      OOD_FILES_APP_REMOTE_FILES:        'true',
      RCLONE_CONFIG_LOCAL_REMOTE_TYPE:   'local',
      RCLONE_CONFIG_ALIAS_REMOTE_TYPE:   'alias',
      RCLONE_CONFIG_ALIAS_REMOTE_REMOTE: "local_remote:#{root_dir}"
    }
  end

  def with_rclone_conf(root_dir, &block)
    conf = remote_files_conf(root_dir)
    with_modified_env(conf, &block)
  end
end