module ModuleBrowserHelper
  def modules_last_updated
    dir = Configuration.module_file_dir
    files = Dir.glob("#{dir}/*.json")
    return nil if files.empty?
    Time.at(files.map { |f| File.mtime(f).to_i }.max)
  end
end
