
Rails.application.config.after_initialize do
  if Rails.env.production?
    old_db_dir = BatchConnect::Session.dataroot.join("db")
    new_db_dir = BatchConnect::Session.db_root

    # have to prep these directories here. Package should have installed
    # Configuration.local_dataroot's parent directory.
    local_dr = Configuration.local_dataroot

    # could be running this while building assets during packaging.
    # if so, just kick out.
    next unless local_dr.parent.exist?

    Dir.mkdir(local_dr, 0o0700) unless Dir.exist?(local_dr)
    FileUtils.mkdir_p(new_db_dir) unless Dir.exist?(new_db_dir)

    next if !old_db_dir.exist? || old_db_dir.empty?

    Dir.children(old_db_dir.to_s) do |db_file|
      FileUtils.copy("#{old_db_dir}/#{db_file}", "#{new_db_dir}/#{db_file}")
    end
  end
end