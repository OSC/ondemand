class Files

  def self.raise_if_cant_access_directory_contents(path)
    # try to actually access directory contents
    # if an exception is raised, we do not have access
    path.each_child.first
  end

  #FIXME: a more generic name for this?
  FileToZip = Struct.new(:path, :relative_path)

  def self.files_to_zip(path)
    path = path.expand_path

    Pathname.new(path).glob('**/*').map {|p|
      FileToZip.new(p.to_s, p.relative_path_from(path).to_s)
    }
  end


  def ls(dirpath)
    Pathname.new(dirpath).each_child.map do |path|
      Files.stat(path)
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def self.stat(path)
    path = Pathname.new(path)

    # path.stat will not work for a symlink and will raise an exception
    # if the directory or file being pointed at does not exist
    begin
      s = path.stat
    rescue
      s = path.lstat
    end

    {
      id: "dev-#{s.dev}-inode-#{s.ino}",
      name: path.basename,
      size: s.directory? ? nil : s.size,
      human_size: s.directory? ? '-' : ::ApplicationController.helpers.number_to_human_size(s.size, precision: 3),
      directory: s.directory?,
      date: s.mtime.to_i,
      owner: username(s.uid),
      mode: s.mode,
      dev: s.dev
    }
  end

  def self.can_download_as_zip?(path, timeout: 10, max_download_as_zip_size: 10*1024*1024*1024)
    path = Pathname.new(path)

    can_download = false
    error = nil

    if ! (path.directory? && path.readable? && path.executable?)
      error = "You can only download a directory as zip that you have read and execute access to"
    else
      o, e, s = Open3.capture3("timeout", "#{timeout}s", "du", "-cbs", path.to_s)

      if s.exitstatus == 124
        error = "Timeout while trying to determine directory size"
      elsif ! s.success?
        error = "Error with status #{s} when trying to determine directory size: #{e}"
      else
        size = o&.split&.first

        if size.blank?
          error "Failed to properly parse the output of the du command when trying to determine directory size."
        elsif size.to_i > max_download_as_zip_size
          error = "The directory is too large to download as a zip. The directory should be less than #{max_download_as_zip_size} bytes."
        else
          can_download = true
        end
      end
    end

    return can_download, error
  end

  # TODO: move to PosixFile
  def self.mime_type(path)
    path = Pathname.new(path.to_s)

    type = %x[ file -b --mime-type #{path.to_s.shellescape} ].strip

    # unfortunately, with the file command, we have this:
    #
    # > If the file named by the file operand does not exist, cannot be read,
    # > or the type of the file named by the file operand cannot be determined,
    # > this is not be considered an error that affects the exit status.
    #
    # so instead we validate it against a regex that match mimetypes
    raise "not valid mimetype: #{type}" unless type =~ /^\w+\/[-+\.\w]+$/

    # if you touch a file and it is empty, the mime type is "inode/x-empty"
    # but in our interaction with the file we would treat this as "text/plain"
    # so we return "text/plain" so web browsers treat it as so
    if type == "inode/x-empty"
      "text/plain"
    else
      type
    end
  end

  # returns mime type string if found, "" otherwise
  def self.mime_type_by_extension(path)
    Mime::Type.lookup_by_extension(Pathname.new(path.to_s).extname.delete_prefix('.'))
  end

  def self.username(uid)
    @username_for_ids ||= Hash.new do |h, key|
      h[key] = begin
        Etc.getpwuid(uid).name
      rescue
        uid
      end
    end
    @username_for_ids[uid]
  end

  def num_files(from, names)
    args = names.map {|n| Shellwords.escape(n) }.join(' ')
    o, e, s = Open3.capture3("find 2>/dev/null #{args} | wc -l", chdir: from)

    # FIXME: handle status error
    o.lines.last.to_i
  end
end
