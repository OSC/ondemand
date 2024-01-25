# frozen_string_literal: true

Rails.application.config.after_initialize do
  old_default = "#{Configuration.dataroot}/.ood"
  new_file_location = Configuration.user_settings_file
  new_file_dir = Pathname.new(new_file_location).parent

  next if File.exist?(new_file_location)

  FileUtils.mkdir_p(new_file_dir) unless File.exist?(new_file_dir.to_s)
  FileUtils.mv(old_default, new_file_location.to_s) if File.exist?(old_default)
end
