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

  class << self
    # Listing helpers for entries where size/directory are already known (e.g. rclone ls).
    def listing_downloadable?(directory:, size: nil)
      return false unless Configuration.download_enabled?
      return true if directory

      size.to_i <= Configuration.download_file_max
    end

    def listing_editable?(directory:, size: nil)
      return false unless Configuration.download_enabled?
      return false if directory
      
      size.to_i <= editor_max_size
    end

    # Raises FilePermissions::Error when the path cannot be opened/viewed as a file.
    def can_open_file!(path)
      file = coerce(path)

      raise Error, I18n.t('dashboard.files_download_not_enabled') unless Configuration.download_enabled?
      if local?(file) && !permitted?(file)
        raise Error, "#{file} does not have an ancestor directory specified in ALLOWLIST_PATH"
      end
      raise Error, I18n.t('dashboard.files_directory_download_unauthorized') unless file.file?

      can_download, error = file.can_download_file?
      raise Error, error unless can_download

      true
    end

    def can_open_file?(path)
      can_open_file!(path)
    rescue Error
      false
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
    # Returns false for non-directories.
    def can_access_directory?(path)
      file = coerce(path)
      return false unless file.directory?
      return false if local?(file) && !permitted?(file)

      file.readable? && executable?(file)
    end

    # Authoritative download check (what the server will allow).
    # Files use can_open_file!; directories need download enabled, allowlist, and readability.
    # Zip size limits stay in can_download_as_zip?. UI listing should use listing_downloadable?.
    def downloadable!(path)
      file = coerce(path)
      return can_open_file!(file) if file.file?

      raise Error, I18n.t('dashboard.files_download_not_enabled') unless Configuration.download_enabled?
      if local?(file) && !permitted?(file)
        raise Error, "#{file} does not have an ancestor directory specified in ALLOWLIST_PATH"
      end
      raise Error, I18n.t('dashboard.files_directory_download_unauthorized') unless file.directory? && file.readable?

      true
    end

    def downloadable?(path)
      downloadable!(path)
    rescue Error
      false
    end

      private

      # Effective editor size limit (smaller of editor and download caps).
      def editor_max_size
        [Configuration.file_editor_max_size, Configuration.download_file_max].min
      end

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

      def permitted?(path)
        AllowlistPolicy.default.permitted?(path_value(path))
      end
      
      def executable?(file)
        !local?(file) || file.path.executable?
      end
  end
end
