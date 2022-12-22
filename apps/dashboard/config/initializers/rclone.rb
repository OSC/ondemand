require 'rclone_util'

Rails.application.config.after_initialize do |_|
  break unless Configuration.remote_files_enabled?

  remotes = RcloneUtil.list_remotes.map { |r| FavoritePath.new('', title: r, filesystem: r) }

  OodFilesApp.candidate_favorite_paths.tap do |paths|
    paths.concat(remotes)
  end
rescue => e
  Rails.logger.error(e.message)
end
