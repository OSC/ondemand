# frozen_string_literal: true

module FilePermissions
  class Error < StandardError; end
  
  # Instance API used when this module is included into a file model.
  def can_open_file?
    FilePermissions.can_open_file?(self)
  end

  def can_edit?
    FilePermissions.can_edit?(self)
  end

  def can_access_directory?
    FilePermissions.can_access_directory?(self)
  end

  def downloadable?
    FilePermissions.downloadable?(self)
  end

  def permitted?
    FilePermissions.permitted?(self)
  end

  class << self
    # Effective editor size limit (smaller of editor and download caps).
    def editor_max_size
      [Configuration.file_editor_max_size, Configuration.download_file_max].min
    end

    # Listing helpers for entries where size/directory are already known (e.g. rclone ls).
    def listing_downloadable?(directory:, size: nil)
      return false unless Configuration.download_enabled?
      return true if directory

      size.to_i <= Configuration.download_file_max
    end

    def listing_editable?(directory:, size: nil)
      !directory && size.to_i <= editor_max_size
    end

    # Whether the user can open/view this path as a file in the Files app.
    # Considers download feature flag, allowlist, POSIX readability, file type, and size.
    def can_open_file?(path)
      open_file(path).first
    end

    # @return [Array(Boolean, String, nil)] whether the file can be opened and an error message
    def open_file(path)
      file = coerce(path)

      return [false, I18n.t('dashboard.files_download_not_enabled')] unless Configuration.download_enabled?
      return allowlist_denied(file) if local?(file) && !permitted?(file)

      file.can_download_file?
    end

    # Raises FilePermissions::Error when the path cannot be opened in the editor.
    # Requires downloads enabled so edit links stay aligned with download UX.
    def can_edit!(path)
      file = coerce(path)

      raise Error, I18n.t('dashboard.files_download_not_enabled') unless Configuration.download_enabled?
      if local?(file) && !permitted?(file)
        raise Error, "#{file} does not have an ancestor directory specified in ALLOWLIST_PATH"
      end
      raise Error, "#{file} is not an editable file" unless file.editable?

      max = editor_max_size
      if file.size > max
        human_max = ActiveSupport::NumberHelper.number_to_human_size(max)
        raise Error, "#{file} exceeds editor limit of #{human_max}. Please download the file to edit or view it locally."
      end

      true
    end

    def can_edit?(path)
      can_edit!(path)
    rescue Error
      false
    end

    # Whether the user can browse this directory in the Files app.
    # Considers allowlist and POSIX directory read/execute bits.
    def can_access_directory?(path)
      file = coerce(path)
      return false if local?(file) && !permitted?(file)

      file.directory? && file.readable? && executable?(file)
    end

    # Whether the Files app should present download/view affordances for this path.
    # Directories only need to be readable; files must also pass can_open_file? rules.
    def downloadable?(path)
      file = coerce(path)
      return false unless Configuration.download_enabled?
      return false if local?(file) && !permitted?(file)
      return false unless file.readable?

      if file.directory?
        true
      elsif file.file?
        can_open_file?(file)
      else
        false
      end
    end

    # Thin wrapper around AllowlistPolicy for a consistent entry point.
    def permitted?(path)
      AllowlistPolicy.default.permitted?(path_value(path))
    end

      private

      # Class#=== is is_a?, so `when PosixFile` matches PosixFile instances.
      def coerce(path)
        case path
        when PosixFile, RemoteFile
          path
        else
          PosixFile.new(path)
        end
      end

      def path_value(path)
        path.respond_to?(:path) ? path.path : path
      end

      def local?(file)
        file.is_a?(PosixFile)
      end

      def executable?(file)
        if file.is_a?(PosixFile)
          file.path.executable?
        else
          true
        end
      end

      def allowlist_denied(file)
        [false, "#{file} does not have an ancestor directory specified in ALLOWLIST_PATH"]
      end
  end
end
