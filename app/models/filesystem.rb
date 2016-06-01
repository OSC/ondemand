require 'open3'
require 'shellwords'

class Filesystem

  # TODO Move this to a config file?
  # /nfs/07 => false
  # /nfs/gpfs/UNAME/template => true
  # /nfs/08/bmcmichael/ood_templ/5/ => true
  #
  # FIXME: I believe that /nfs/home/efranz will be the pattern for the new file
  # system home directory paths, so we should allow for these as well
  #
  # FIXME: regex is probably overkill here since we now are checking the size of
  # the directory
  # COPY_SAFE_PATH_REGEX = %r{^/nfs/([0-9]{2}|gpfs)/\w+/.+}
  # COPY_SAFE_PATH_ERROR_MESSAGE = "The specified path must be under a home directory or in project space."
  MAX_COPY_SAFE_DIR_SIZE = 1024*1024*1024
  MAX_COPY_SAFE_DU_TIMEOUT_SECONDS = 10
  MAX_COPY_TIMEOUT_MESSAGE = "Timeout occurred when trying to determine directory size. " \
    "Size must be computable in less than #{MAX_COPY_SAFE_DU_TIMEOUT_SECONDS} seconds. " \
    "Either directory has too many files or the file system is currently slow (if so, please try again later)."

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
    # FIXME: consider using http://ruby-doc.org/stdlib-2.2.0/libdoc/timeout/rdoc/Timeout.html
    stdout, stderr, status = Open3.capture3 "timeout #{MAX_COPY_SAFE_DU_TIMEOUT_SECONDS}s du -cbs #{Shellwords.escape(path)}"
    return false, MAX_COPY_TIMEOUT_MESSAGE if status.exitstatus == 124
    return false, "Error with status #{status} occurred when trying to determine directory size: #{stderr}" unless status.success?

    safe, error = true, nil
    size = stdout.split.first

    if size.blank?
      safe, error = false, "Failed to properly parse the output of the du command."
    elsif size.to_i > MAX_COPY_SAFE_DIR_SIZE
      safe, error = false, "The directory is too large to copy. The directory should be less than #{MAX_COPY_SAFE_DIR_SIZE} bytes."
    # FIXME: regex is probably overkill here
    # elsif (path =~ COPY_SAFE_PATH_REGEX).nil?
    #   safe, error = false, COPY_SAFE_PATH_ERROR_MESSAGE
    end

    return safe, error
  end

  # Get the disk usage of a path in bytes, nil if path is invalid
  def path_size (path)
    if Dir.exist? path
      Integer(`du -s -b #{path}`.split('/')[0])
    end
  end
end
