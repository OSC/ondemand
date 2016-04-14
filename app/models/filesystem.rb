class Filesystem

  # TODO Move this to a config file?
  # /nfs/07 => false
  # /nfs/gpfs/UNAME/template => true
  # /nfs/08/bmcmichael/ood_templ/5/ => true
  BASE_PATTERN = /\/nfs\/([0-9]{2}|gpfs)\/\w+\/\w+/

  def initialize
    @fs = FileManager[:fs]
    @api = FileManager[:api]
  end

  # Returns an http URI path to the cloudcmd filesystem link
  def fs(path)
    File.join(@fs, path)
  end

  # Returns an http URI path to the cloudcmd api link
  def api(path)
    File.join(@api, path)
  end

  # Matches a pathname on the system to prevent root file system copies.
  def safe_path? (path)
    path =~ BASE_PATTERN ? true : false
  end

  # Get the disk usage of a path in bytes, nil if path is invalid
  def path_size (path)
    if Dir.exist? path
      Integer(`du -s -b #{path}`.split('/')[0])
    end
  end
end
