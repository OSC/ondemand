module ModuleBrowserHelper
  def modules_last_updated
    dir = Configuration.module_file_dir
    files = Dir.glob("#{dir}/*.json")
    return nil if files.empty?
    Time.at(files.map { |f| File.mtime(f).to_i }.max)
  end
  def modules_last_updated_message(time)
    if time
      "(Last updated: #{time.strftime('%Y-%m-%d %H:%M:%S')})"
    else
      "(Last updated: n/a)"
    end
  end
end
