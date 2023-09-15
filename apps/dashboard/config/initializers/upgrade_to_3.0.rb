# frozen_string_literal: true

Rails.application.config.after_initialize do
  # Since https://github.com/OSC/ondemand/pull/1526 all the batch connect cache files
  # have moved. So, when folks upgrade to 3.0, let's sync these old files so that
  # they don't lose their cached choices.
  old_context_files = "#{Configuration.dataroot}/batch_connect/**/*/context.json"
  cache_root = BatchConnect::Session.cache_root

  # kick out if you've already done this
  next if Dir.glob("#{cache_root}/*.json").size.positive?

  Dir.glob(old_context_files).map do |old_file|
    new_filename = old_file.gsub(%r{.*/batch_connect/}, '').gsub('/context.json', '').gsub('/', '_')
    new_filename = "#{new_filename}.json"

    new_file = "#{cache_root}/#{new_filename}"
    if !File.exist?(new_file)
      FileUtils.cp(old_file, new_file)
    elsif File.mtime(old_file) > File.mtime(new_file)
      FileUtils.cp(old_file, new_file)
    end
  end
end
