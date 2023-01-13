# frozen_string_literal: true

Rails.application.config.after_initialize do
  next unless Configuration.bc_clean_old_dirs?

  config_days = Configuration.bc_clean_old_dirs_days.to_i
  config_days = 30 if config_days.zero? || config_days.negative?

  thirty_day_seconds = config_days * 24 * 60 * 60
  thirty_days_ago = Time.now - thirty_day_seconds

  all_bc_dirs = Dir.glob("#{Configuration.dataroot}/batch_connect/**/output/*")
  all_bc_dirs.each do |dir|
    ctime = File.ctime(dir)
    CleanDirectoryJob.perform_later(dir) if ctime < thirty_days_ago
  end
end
