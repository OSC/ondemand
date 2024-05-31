# frozen_string_literal: true

# helper functions for tests that use rclone/remote files in files app

module ActiveSupport
  class TestCase
    # Avoid using local remote directly to detect cases where the path is valid on both the remote
    # and posix file system
    def remote_files_conf(root_dir)
      {
        OOD_REMOTE_FILES_ENABLED:          'true',
        RCLONE_CONFIG_LOCAL_REMOTE_TYPE:   'local',
        RCLONE_CONFIG_ALIAS_REMOTE_TYPE:   'alias',
        RCLONE_CONFIG_ALIAS_REMOTE_REMOTE: "local_remote:#{root_dir}",
        RCLONE_CONFIG:                     Rails.root.join('test/fixtures/config/rclone/rclone.conf').to_s
      }
    end

    def with_rclone_conf(root_dir, &block)
      conf = remote_files_conf(root_dir)
      with_modified_env(conf, &block)
    end

    def with_extra_rclone_conf(root_dir, &block)
      conf = remote_files_conf(root_dir)
             .merge({ OOD_RCLONE_EXTRA_CONFIG: Rails.root.join('test/fixtures/config/rclone/extra_config.conf').to_s })
      with_modified_env(conf, &block)
    end
  end
end
