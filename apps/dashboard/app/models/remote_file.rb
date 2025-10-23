# frozen_string_literal: true

require 'rclone_util'

# PosixFile is a class representing a file on a remote file system.
class RemoteFile
  attr_reader :path, :remote

  delegate :basename, :descend, :parent, :join, :to_s, to: :path

  def initialize(path, remote)
    # accepts both String and Pathname
    # avoids converting to Pathname in every function
    @path = Pathname.new(path)
    @remote = remote
  end

  def remote_type
    @remote_type ||= RcloneUtil.remote_type(remote)
  end

  def raise_if_cant_access_directory_contents; end

  def directory?
    RcloneUtil.directory?(remote, path)
  end

  def ls
    files = RcloneUtil.ls(remote, path)
    # Need to return same fields as PosixFile.
    # owner, mode and dev are not defined for remote files, leaving them empty
    files.map do |file|
      {
        id:           file['Path'],
        name:         file['Name'],
        size:         file['IsDir'] ? nil : file['Size'],
        directory:    file['IsDir'],
        date:         DateTime.parse(file['ModTime']).to_time.to_i,
        owner:        '',
        mode:         '',
        dev:          0,
        downloadable: true
      }
    end.select do |stats|
      valid_encoding = stats[:name].to_s.valid_encoding?
      Rails.logger.warn("Not showing file '#{stats[:name]}' because it is not a UTF-8 filename.") unless valid_encoding
      valid_encoding
    end.sort_by { |p| p[:directory] ? 0 : 1 }
  end

  def can_download_as_zip?(timeout: Configuration.file_download_dir_timeout, download_directory_size_limit: Configuration.file_download_dir_max)
    [false, 'Downloading remote files as zip is currently not supported']
  end

  def editable?
    # Assume file is editable if it exists and isn't a directory even though it
    # might not actually be (e.g. permissions)
    !directory?
  rescue StandardError => e
    false
  end

  def read(&block)
    RcloneUtil.cat(remote, path, &block)
  end

  def touch
    RcloneUtil.touch(remote, path)
  end

  def mkdir
    RcloneUtil.mkdir(remote, path)
  end

  def write(content)
    RcloneUtil.write(remote, path, content)
  end

  def handle_upload(tempfile)
    # Start a transfer that moves the Rack tempfile to the remote.
    transfer = RemoteTransfer.build(
      action: "mv",
      files: { tempfile.path => path.to_s },
      src_remote: RcloneUtil::LOCAL_FS_NAME,
      dest_remote: remote,
      tempfile: tempfile
    )
    transfer.tap(&:perform_later)
  end

  def size
    RcloneUtil.size(remote, path)["bytes"]
  end

  def mime_type
    # Rclone does not return same mime types as `file -b --mime-type` used in PosixFile
    # Results in shell scripts not being viewable as they are application/x-sh and not text/x-shellscript
    #
    # TODO: Could something like `rclone cat --head <N> <remote>:<path> | file -b --mime-type -`
    # be used here to have consistent filetypes with PosixFile
    RcloneUtil.mime_type(remote, path)
  end

  # allow implicit conversion to String
  def to_str
    to_s
  end
end
