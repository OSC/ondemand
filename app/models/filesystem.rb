class Filesystem

  # TODO Move this to a config file?
  # /nfs/07 => false
  # /nfs/gpfs/UNAME/template => true
  # /nfs/08/bmcmichael/ood_templ/5/ => true
  BASE_PATTERN = %r{^/nfs/([0-9]{2}|gpfs)/\w+/.+}

  # Returns an http URI path to the cloudcmd filesystem link
  def fs(path)
    OodAppkit.files.url(path: path).to_s
  end

  # Returns an http URI path to the cloudcmd api link
  def api(path)
    OodAppkit.files.api(path: path).to_s
  end

  # Matches a pathname on the system to prevent root file system copies.
  def safe_path? (path)
    if path =~ BASE_PATTERN
      return true, nil
    else
      return false, "path invalid"
    end
  end

  # Get the disk usage of a path in bytes, nil if path is invalid
  def path_size (path)
    if Dir.exist? path
      Integer(`du -s -b #{path}`.split('/')[0])
    end
  end
end
