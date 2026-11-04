# frozen_string_literal: true

class FilePermissions
  class << self
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

    # Whether the user can open this path in the file editor.
    # Considers allowlist, POSIX read/write, file type, and editor size limits.
    def can_edit_file?(path)
      edit_file(path).first
    end

    # @return [Array(Boolean, String, nil)] whether the file can be edited and an error message
    def edit_file(path)
      file = coerce(path)

      return allowlist_denied(file) if local?(file) && !permitted?(file)
      return [false, "#{file} is not an editable file"] unless file.editable?

      editor_max = [Configuration.file_editor_max_size, Configuration.download_file_max].min
      if file.size > editor_max
        human_max = ActiveSupport::NumberHelper.number_to_human_size(editor_max)
        return [false, "#{file} exceeds editor limit of #{human_max}. Please download the file to edit or view it locally."]
      end

      [true, nil]
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
