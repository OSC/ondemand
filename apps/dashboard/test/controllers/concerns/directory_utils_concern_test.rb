require 'test_helper'

class DirectoryUtilsConcernTest < ActiveSupport::TestCase
  class DummyController
    include DirectoryUtilsConcern

    attr_accessor :resolved_path_value, :resolved_fs_value

    def resolved_path
      resolved_path_value
    end

    def resolved_fs
      resolved_fs_value
    end
  end

  def setup
    @controller = DummyController.new
    @date1 = 2.months.ago.to_i.to_s
    @date2 = 2.weeks.ago.to_i.to_s
    @date3 = 2.days.ago.to_i.to_s
    @date4 = 2.hours.ago.to_i.to_s
    @files = files = [
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 }
    ]
  end

  # Tests for DirectoryUtilsConcern#normalized_path
  test 'normalized_path with empty path' do
    path = @controller.normalized_path('')
    assert_equal '/', path.to_s
  end

  test 'normalized_path with root path' do
    path = @controller.normalized_path('/')
    assert_equal '/', path.to_s
  end

  test 'normalized_path with posix path' do
    path = @controller.normalized_path('/foo/bar/file.txt')
    assert_equal '/foo/bar/file.txt', path.to_s
  end

  test 'normalized_path with posix path without slash' do
    path = @controller.normalized_path('foo/bar')
    assert_equal '/foo/bar', path.to_s
  end

  # Tests for DirectoryUtilsConcern#parse_path
  test 'parse_path with empty path' do
    @controller.resolved_path_value = ''
    @controller.resolved_fs_value = 'fs'

    @controller.parse_path

    assert_instance_of PosixFile, @controller.instance_variable_get(:@path)
    assert_equal 'fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with root path' do
    @controller.resolved_path_value = '/'
    @controller.resolved_fs_value = 'fs'

    @controller.parse_path

    assert_instance_of PosixFile, @controller.instance_variable_get(:@path)
    assert_equal 'fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with posix path' do
    @controller.resolved_path_value = '/foo/bar/file.txt'
    @controller.resolved_fs_value = 'fs'

    @controller.parse_path

    assert_instance_of PosixFile, @controller.instance_variable_get(:@path)
    assert_equal 'fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with posix path without slash' do
    @controller.resolved_path_value = 'foo/bar'
    @controller.resolved_fs_value = 'fs'

    @controller.parse_path

    assert_instance_of PosixFile, @controller.instance_variable_get(:@path)
    assert_equal 'fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with empty remote path' do
    @controller.resolved_path_value = ''
    @controller.resolved_fs_value = 'remote_fs'
    Configuration.stubs(:remote_files_enabled?).returns(true)

    @controller.parse_path

    assert_instance_of RemoteFile, @controller.instance_variable_get(:@path)
    assert_equal 'remote_fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with filesystem fs' do
    @controller.resolved_path_value = '/some/path'
    @controller.resolved_fs_value = 'fs'

    @controller.parse_path

    assert_instance_of PosixFile, @controller.instance_variable_get(:@path)
    assert_equal 'fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path with remote filesystem when enabled' do
    @controller.resolved_path_value = '/remote/path'
    @controller.resolved_fs_value = 'remote_fs'
    Configuration.stubs(:remote_files_enabled?).returns(true)

    @controller.parse_path

    assert_instance_of RemoteFile, @controller.instance_variable_get(:@path)
    assert_equal 'remote_fs', @controller.instance_variable_get(:@filesystem)
  end

  test 'parse_path raises error when remote files are disabled' do
    @controller.resolved_path_value = '/remote/path'
    @controller.resolved_fs_value = 'remote_fs'
    Configuration.stubs(:remote_files_enabled?).returns(false)

    assert_raises(StandardError, 'Remote files are disabled') do
      @controller.parse_path
    end
  end

  # Tests for DirectoryUtilsConcern#validate_path!
  test 'validate_path! raises error when remote_type is nil' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns(nil)
    remote_path.stubs(:remote).returns('nonexistent_remote')
    @controller.instance_variable_set(:@path, remote_path)

    error = assert_raises(StandardError) { @controller.validate_path! }
    assert_equal 'Remote nonexistent_remote does not exist', error.message
  end

  test 'validate_path! raises error when allowlist_paths is present and remote_type is local' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('local')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns(['/some/path'])

    error = assert_raises(StandardError) { @controller.validate_path! }
    assert_equal 'Remotes of type local are not allowed due to ALLOWLIST_PATH', error.message
  end

  test 'validate_path! raises error when allowlist_paths is present and remote_type is alias' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('alias')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns(['/some/path'])

    error = assert_raises(StandardError) { @controller.validate_path! }
    assert_equal 'Remotes of type alias are not allowed due to ALLOWLIST_PATH', error.message
  end

  test 'validate_path! passes when allowlist_paths is not present and remote_type is acceptable' do
    @controller.stubs(:posix_file?).returns(false)
    remote_path = mock('RemoteFile')
    remote_path.stubs(:remote_type).returns('sshfs')
    @controller.instance_variable_set(:@path, remote_path)
    Configuration.stubs(:allowlist_paths).returns([])

    assert_nothing_raised { @controller.validate_path! }
  end

  # Tests for DirectoryUtilsConcern#set_files
  test 'set_files sets @files correctly' do
    path = mock('PosixFile')
    path.stubs(:ls).returns([{ name: 'file1', directory: false }, { name: 'dir1', directory: true }])
    @controller.instance_variable_set(:@path, path)
    @controller.instance_variable_set(:@sory_by, 'name')

    @controller.set_files('name')

    files = @controller.instance_variable_get(:@files)
    assert_equal [{ name: 'dir1', directory: true }, { name: 'file1', directory: false }], files
  end

  # Tests for DirectoryUtilsConcern#sort_by_column
  test 'sort_by_column sorts by type' do
    @files
    sorted_files = @controller.sort_by_column(@files, 'type')
    assert_equal [
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 }
    ], sorted_files
  end

  test 'sort_by_column sorts by name' do
    @files
    sorted_files = @controller.sort_by_column(@files, 'name')
    assert_equal [
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 }
    ], sorted_files
  end

  test 'sort_by_column sorts by size' do
    @files
    sorted_files = @controller.sort_by_column(@files, 'size')
    assert_equal [
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 }
    ], sorted_files
  end

  test 'sort_by_column sorts by date' do
    @files
    sorted_files = @controller.sort_by_column(@files, 'date')
    assert_equal [
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 },
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 }
    ], sorted_files
  end

  test 'sort_by_column sorts by owner' do
    @files
    sorted_files = @controller.sort_by_column(@files, 'owner')
    assert_equal [
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 }
    ], sorted_files
  end

  test 'sort_by_column sorts by mode' do
    sorted_files = @controller.sort_by_column(@files, 'mode')
    assert_equal [
      { id: 'bcde2345', name: 'dir2', size: nil, directory: true, date: @date4, owner: 'dtenant', mode: 16877 },
      { id: 'defg4567', name: 'dir1', size: nil, directory: true, date: @date1, owner: 'pcapaldi', mode: 16877 },
      { id: 'abcd1234', name: 'file1', size: 8166357, directory: false, date: @date2, owner: 'msmith', mode: 33188 },
      { id: 'cdef3456', name: 'file2', size: 816, directory: false, date: @date3, owner: 'tbaker', mode: 33188 }
    ], sorted_files
  end


  # Tests for DirectoryUtilsConcern#posix_file?
  test 'posix_file? returns true when @path is a PosixFile' do
    path = PosixFile.new('/some/path')
    @controller.instance_variable_set(:@path, path)
    assert @controller.posix_file?
  end

  test 'posix_file? returns false when @path is a RemoteFile' do
    path = RemoteFile.new('/some/path', 'remote_fs')
    @controller.instance_variable_set(:@path, path)
    refute @controller.posix_file?
  end
end