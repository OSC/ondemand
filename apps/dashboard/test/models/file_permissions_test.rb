# frozen_string_literal: true

require 'test_helper'

class FilePermissionsTest < ActiveSupport::TestCase
  test 'can_open_file? is true for a readable file within the size limit' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'open.txt').tap { |path| File.write(path, 'hello') }

      assert FilePermissions.can_open_file?(file)
      assert_equal [true, nil], FilePermissions.open_file(file)
    end
  end

  test 'can_open_file? is false when downloads are disabled' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'open.txt').tap { |path| FileUtils.touch(path) }
      Configuration.stubs(:download_enabled?).returns(false)

      refute FilePermissions.can_open_file?(file)
      assert_equal [false, I18n.t('dashboard.files_download_not_enabled')], FilePermissions.open_file(file)
    end
  end

  test 'can_open_file? is false for unreadable files' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'secret.txt').tap { |path| FileUtils.touch(path) }
      FileUtils.chmod(0o0333, file)

      refute FilePermissions.can_open_file?(file)
    end
  end

  test 'can_open_file? is false when the file exceeds the download size limit' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'big.txt').tap { |path| FileUtils.touch(path) }
      Pathname.any_instance.stubs(:lstat).returns(OpenStruct.new(size: Configuration.download_file_max + 1, symlink?: false))

      refute FilePermissions.can_open_file?(file)
      result, error = FilePermissions.open_file(file)
      refute result
      assert_equal I18n.t('dashboard.files_file_too_large', download_file_size_limit: Configuration.download_file_max), error
    end
  end

  test 'can_open_file? is false for paths outside the allowlist' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: "#{dir}/allowed" }) do
        FileUtils.mkdir_p("#{dir}/allowed")
        FileUtils.mkdir_p("#{dir}/blocked")
        file = File.join(dir, 'blocked', 'file.txt').tap { |path| FileUtils.touch(path) }

        refute FilePermissions.can_open_file?(file)
        refute FilePermissions.permitted?(file)
      end
    end
  end

  test 'can_edit_file? is true for a writable file within the editor limit' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'edit.txt').tap { |path| File.write(path, 'edit me') }

      assert FilePermissions.can_edit_file?(file)
      assert_equal [true, nil], FilePermissions.edit_file(file)
    end
  end

  test 'can_edit_file? is false for read-only files' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'readonly.txt').tap { |path| FileUtils.touch(path) }
      FileUtils.chmod(0o0444, file)

      refute FilePermissions.can_edit_file?(file)
    end
  end

  test 'can_edit_file? is false when the file exceeds the editor size limit' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'too_big.txt').tap { |path| FileUtils.touch(path) }
      editor_max = [Configuration.file_editor_max_size, Configuration.download_file_max].min
      Pathname.any_instance.stubs(:lstat).returns(OpenStruct.new(size: editor_max + 1, symlink?: false))

      refute FilePermissions.can_edit_file?(file)
      result, error = FilePermissions.edit_file(file)
      refute result
      assert_match(/exceeds editor limit/, error)
    end
  end

  test 'can_access_directory? is true for a readable and executable directory' do
    Dir.mktmpdir do |dir|
      assert FilePermissions.can_access_directory?(dir)
    end
  end

  test 'can_access_directory? is false for an unreadable directory' do
    Dir.mktmpdir do |dir|
      FileUtils.chmod(0o0333, dir)

      refute FilePermissions.can_access_directory?(dir)
    ensure
      FileUtils.chmod(0o0755, dir)
    end
  end

  test 'can_access_directory? is false for directories outside the allowlist' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: "#{dir}/allowed" }) do
        FileUtils.mkdir_p("#{dir}/allowed")
        blocked = File.join(dir, 'blocked').tap { |path| FileUtils.mkdir_p(path) }

        refute FilePermissions.can_access_directory?(blocked)
        assert FilePermissions.can_access_directory?("#{dir}/allowed")
      end
    end
  end

  test 'downloadable? is false for files that cannot be opened' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'big.txt').tap { |path| FileUtils.touch(path) }
      Pathname.any_instance.stubs(:lstat).returns(OpenStruct.new(size: Configuration.download_file_max + 1, symlink?: false))

      refute FilePermissions.downloadable?(file)
    end
  end

  test 'downloadable? is true for readable directories when downloads are enabled' do
    Dir.mktmpdir do |dir|
      assert FilePermissions.downloadable?(dir)
    end
  end

  test 'PosixFile#to_h exposes editable using FilePermissions' do
    Dir.mktmpdir do |dir|
      writable = File.join(dir, 'writable.txt').tap { |path| FileUtils.touch(path) }
      readonly = File.join(dir, 'readonly.txt').tap { |path| FileUtils.touch(path) }
      FileUtils.chmod(0o0444, readonly)

      assert PosixFile.new(writable).to_h[:editable]
      refute PosixFile.new(readonly).to_h[:editable]
    end
  end
end
