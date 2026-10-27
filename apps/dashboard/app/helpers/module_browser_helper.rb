module ModuleBrowserHelper
  def modules_last_updated
    dir = Configuration.module_file_dir
    files = Dir.glob("#{dir}/*.json")
    return 'n/a' if files.empty?

    latest_mtime = files.map { |f| File.mtime(f) }.max
    latest_mtime.strftime('%Y-%m-%d %H:%M:%S')
  end
end
