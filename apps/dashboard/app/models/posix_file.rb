# PosixFile is a class representing a file on a local file system.
class PosixFile

  attr_reader :path

  delegate :basename, :descend, :parent, :join, :to_s, :read, :write, :mkdir, to: :path

  class << self
    def stat(path)
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
        owner: username_from_cache(s.uid),
        mode: s.mode,
        dev: s.dev
      }
    end

    def num_files(from, names)
      args = names.map {|n| Shellwords.escape(n) }.join(' ')
      o, e, s = Open3.capture3("find 2>/dev/null #{args} | wc -l", chdir: from)

      # FIXME: handle status error
      o.lines.last.to_i
    end

    def username(uid)
      begin
        Etc.getpwuid(uid).name
      rescue
        uid.to_s
      end
    end

    def username_from_cache(uid)
      @username_for_ids ||= Hash.new do |h, key|
        h[key] = username(key)
      end

      @username_for_ids[uid]
    end
  end

  def initialize(path)
    # accepts both String and Pathname
    # avoids converting to Pathname in every function
    @path = Pathname.new(path)
  end

  def raise_if_cant_access_directory_contents
    # try to actually access directory contents
    # if an exception is raised, we do not have access
    path.each_child.first
  end

  #FIXME: a more generic name for this?
  FileToZip = Struct.new(:path, :relative_path)

  def files_to_zip
    expanded = path.expand_path

    expanded.glob('**/*').map { |p|
      FileToZip.new(p.to_s, p.relative_path_from(expanded).to_s)
    }
  end

  def directory?
    path.stat.directory?
  end

  def ls
    path.each_child.map do |child_path|
      PosixFile.stat(child_path)
    end.select do |stats|
      valid_encoding = stats[:name].to_s.valid_encoding?
      Rails.logger.warn("Not showing file '#{stats[:name]}' because it is not a UTF-8 filename.") unless valid_encoding
      valid_encoding
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def editable?
    path.file? && path.readable? && path.writable?
  end

  def touch
    FileUtils.touch(path)
  end

  def mv_from(src)
    FileUtils.mv(src, path)
  end

  def handle_upload(tempfile)
    path.parent.mkpath unless path.parent.directory?

    mode = if path.exist?
             # file aleady exists, so use it's existing permissions
             path.stat.mode
           else
             # Apply the user's umask on top of 0666 (-rw-rw-rw-), since the file doesn't need to be executable.
             0o666 & (0o777 ^ File.umask)
           end

    FileUtils.mv tempfile, path.to_s
    File.chmod(mode, path.to_s)

    path.chown(nil, path.parent.stat.gid) if path.parent.setgid?
  end

  def can_download_as_zip?(timeout: Configuration.file_download_dir_timeout, download_directory_size_limit: Configuration.file_download_dir_max)
    can_download = false
    error = nil

    if ! (path.directory? && path.readable? && path.executable?)
      error = I18n.t('dashboard.files_directory_download_unauthorized')
    else
      # Determine the size of the directory.
      o, e, s = Open3.capture3("timeout", "#{timeout}s", "du", "-cbs", path.to_s)

      # Catch SIGTERM.
      if s.exitstatus == 124
        error = I18n.t('dashboard.files_directory_size_calculation_timeout')
      elsif ! s.success?
        error = I18n.t('dashboard.files_directory_size_unknown', exit_code: s, error: e)
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

        if size.blank?
          error = I18n.t('dashboard.files_directory_size_calculation_error')
        elsif size.to_i > download_directory_size_limit
          error = I18n.t('dashboard.files_directory_too_large', download_directory_size_limit: download_directory_size_limit)
        elsif size.to_i == 0
          error = I18n.t('dashboard.files_directory_download_size_0', cmd: "timeout 10s du -cbs #{path.to_s}")
        else
          can_download = true
        end
      end
    end

    return can_download, error
  end

  def mime_type
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

  # allow implicit conversion to String
  def to_str
    to_s
  end
end
