require 'open3'
require 'shellwords'

class Filesystem

  class << self
    attr_accessor :max_copy_safe_dir_size, :max_copy_safe_du_timeout_seconds

    def max_copy_safe_dir_size 
      @max_copy_safe_dir_size ||= 1024*1024*1024
    end

    def max_copy_safe_du_timeout_seconds
      @max_copy_safe_du_timeout_seconds ||= 10
    end
  end


  MAX_COPY_TIMEOUT_MESSAGE = "Timeout occurred when trying to determine directory size. " \
    "Size must be computable in less than #{max_copy_safe_du_timeout_seconds} seconds. " \
    "Either directory has too many files or the file system is currently slow (if so, please try again later)."

  # Returns a http URI path to the cloudcmd filesystem link
  def fs(path)
    OodAppkit.files.url(path: path).to_s
  end

  # Returns a http URI path to the cloudcmd api link
  def api(path)
    OodAppkit.files.api(path: path).to_s
  end

  # Returns a http URI path the the file editor link
  def editor(path)
    OodAppkit.editor.edit(path: path).to_s
  end

  # Verify that this path is safe to copy recursively from
  #
  # Matches a pathname on the system to prevent root file system copiesa
  # FIXME: this should be a validation on template when creating a new template
  # unfortunately the template's source path and @source for the template Source
  # directory are two very different things and so naming is confusing...
  def validate_path_is_copy_safe(path)
    # FIXME: this is hack till we can move this to controllers or form objects
    # and do proper testing
    begin
      unless WhitelistPolicy.new(Configuration.whitelist_paths).permitted?(path)
        return false, "No permission to use the path due to the whitelist policy."
      end
    rescue ArgumentError => e
      return false, "#{e.class} when testing path #{path} against whitelist: #{e.message}"
    end

    # FIXME: consider using http://ruby-doc.org/stdlib-2.2.0/libdoc/timeout/rdoc/Timeout.html
    stdout, stderr, status = du(path, self.class.max_copy_safe_du_timeout_seconds)
    return false, MAX_COPY_TIMEOUT_MESSAGE if status.exitstatus == 124
    return false, "Error with status #{status} occurred when trying to determine directory size: #{stderr}" unless status.success?

    safe, error = true, nil
    size = stdout.split.first

    if size.blank?
      safe, error = false, "Failed to properly parse the output of the du command."
    elsif size.to_i > self.class.max_copy_safe_dir_size
      safe, error = false, "The directory is too large to copy. The directory should be less than #{self.class.max_copy_safe_dir_size} bytes."
    end

    return safe, error
  end

  def du(path, timeout)
    Open3.capture3 "timeout #{timeout}s du -cbs #{Shellwords.escape(path)}"
  end

  # FIXME: some duplication here between du command above and this; we probably
  # want to use the above
  #
  # Get the disk usage of a path in bytes, nil if path is invalid
  def path_size (path)
    if Dir.exist? path
      Integer(`du -s -b #{path}`.split('/')[0])
    end
  end
end
