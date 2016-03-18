class Filesystem

  def initialize
    @fs = FileManager[:fs]
    @api = FileManager[:api]
  end

  def fs(path)
    File.join(@fs, path)
  end

  def api(path)
    File.join(@api, path)
  end
end
