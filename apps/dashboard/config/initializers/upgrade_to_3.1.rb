# frozen_string_literal: true

Rails.application.config.after_initialize do
  old_default = "#{Configuration.dataroot}/.ood"
  new_file_location = Configuration.user_settings_file

  next if File.exist?(new_file_location)

  FileUtils.mv(old_default, new_file_location) if File.exist?(old_default)
end
