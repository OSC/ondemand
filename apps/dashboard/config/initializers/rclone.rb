require 'rclone_util'

Rails.application.config.after_initialize do
  next unless Configuration.remote_files_enabled?

  remotes = RcloneUtil.list_remotes.map { |r| FavoritePath.new('', title: r, filesystem: r) }

  OodFilesApp.candidate_favorite_paths.tap do |paths|
    paths.concat(remotes)
  end
rescue => e
  Rails.logger.error("Cannot add rclone favorite paths because #{e.message}")
end
