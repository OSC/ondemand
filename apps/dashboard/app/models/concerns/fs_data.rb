module FsData
  # Returns the size of a directory in bytes for a given pathname. Pathname can be string or Pathname object.
  def directory_size(pathname, timeout: Configuration.file_download_dir_timeout, collect_error: false)
    path = Pathname.new pathname
    # Determine the size of the directory.
    o, e, s = Open3.capture3("timeout", "#{timeout}s", "du", "-cbs", path.to_s)

    # Catch SIGTERM.
    if s.exitstatus == 124
      error = I18n.t('dashboard.files_directory_size_calculation_timeout')
    elsif ! s.success?
      error = I18n.t('dashboard.files_directory_size_unknown', exit_code: s.exitstatus, error: e)
    else
      # Example output from: du -cbs $path
      #
      #    496184  .
      #    64      ./ood-portal-generator/lib/ood_portal_generator
      #    72      ./ood-portal-generator/lib
      #    24      ./ood-portal-generator/templates
      #    40      ./ood-portal-generator/share
      #    576     ./ood-portal-generator
      #
      size = o&.split&.first
    end
    collect_error ? [size, error] : size
  end
end
    