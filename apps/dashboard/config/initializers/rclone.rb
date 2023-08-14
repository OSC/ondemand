require 'rclone_util'

Rails.application.config.after_initialize do
  next unless Configuration.remote_files_enabled?

  remotes = RcloneUtil.list_remotes

  if Configuration.remote_files_validation?
    # Query remotes in parallel
    mutex = Mutex.new
    remotes.map do |remote|
      Thread.new do
        valid = RcloneUtil.valid?(remote)
        mutex.synchronize { remotes.delete(remote) } unless valid
      end
    end.each(&:join)
  end

  OodFilesApp.candidate_favorite_paths.tap do |paths|
    paths.concat(remotes.map { |r| FavoritePath.new('', title: r, filesystem: r) })
  end
rescue => e
  Rails.logger.error("Cannot add rclone favorite paths because #{e.message}")
end
