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

  # Verify that this path is safe to copy recursively from
  #
  # Matches a pathname on the system to prevent root file system copiesa
  # FIXME: this should be a validation on template when creating a new template
  # unfortunately the template's source path and @source for the template Source
  # directory are two very different things and so naming is confusing...
  def validate_path_is_copy_safe(path)
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
