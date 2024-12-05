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
    @date4 = 2.hours.ago.to_i.to_s
    @date3 = 2.days.ago.to_i.to_s
    @date2 = 2.weeks.ago.to_i.to_s
    @date1 = 2.months.ago.to_i.to_s
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

  # Tests for DirectoryUtilsConcern#sort_by_column
  test 'set_sorting_params sets @sorting_params correctly with valid parameters' do
    parameters = { col: 'name', direction: DirectoryUtilsConcern::ASCENDING, grouped?: true }
    @controller.set_sorting_params(parameters)
    expected_params = { col: 'name', direction: DirectoryUtilsConcern::ASCENDING, grouped?: true }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end

  test 'set_sorting_params sets @sorting_params correctly with descending sort direction' do
    parameters = { col: 'name', direction: DirectoryUtilsConcern::DESCENDING, grouped?: true }
    @controller.set_sorting_params(parameters)
    expected_params = { col: 'name', direction: DirectoryUtilsConcern::DESCENDING, grouped?: true }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end

  test 'set_sorting_params sets @sorting_params with missing grouped? parameter' do
    parameters = { col: 'size', direction: DirectoryUtilsConcern::DESCENDING }
    @controller.set_sorting_params(parameters)
    expected_params = { col: 'size', direction: DirectoryUtilsConcern::DESCENDING, grouped?: true }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end

  test 'set_sorting_params sets @sorting_params with missing direction parameter' do
    parameters = { col: 'modified_at', grouped?: false }
    @controller.set_sorting_params(parameters)
    expected_params = { col: 'modified_at', direction: true, grouped?: false }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end

  test 'set_sorting_params sets @sorting_params with empty parameters' do
    parameters = {}
    @controller.set_sorting_params(parameters)
    expected_params = { col: "name", direction: true, grouped?: true }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end

  # Tests for DirectoryUtilsConcern#set_files
  test 'set_files sets @files correctly' do
    path = mock('PosixFile')
    path.stubs(:ls).returns([{ name: 'file1', directory: false }, { name: 'dir1', directory: true }])
    @controller.instance_variable_set(:@path, path)
    @controller.instance_variable_set(:@sorting_params, { col: 'name', direction: true, grouped?: true })

    @controller.set_files

    files = @controller.instance_variable_get(:@files)
    assert_equal [{ name: 'dir1', directory: true }, { name: 'file1', directory: false }], files
  end

  # Tests for DirectoryUtilsConcern#group_by_type
  test 'group_by_type groups directories and files' do
    files = [
      { name: 'file1', directory: false },
      { name: 'dir1', directory: true },
      { name: 'file2', directory: false },
      { name: 'dir2', directory: true }
    ]
    
    grouped_files = @controller.group_by_type(files)
    assert_equal [
      { name: 'dir1', directory: true },
      { name: 'dir2', directory: true },
      { name: 'file1', directory: false },
      { name: 'file2', directory: false }
      ], grouped_files    
  end

  # Tests for DirectoryUtilsConcern#sort_by_column
  test 'sort_by_column sorts files by size' do
    files = [
      { name: 'file2', size: 100, owner: 'user1', date: @date1 },
      { name: 'file3', size: 25, owner: 'user2', date: @date2 },
      { name: 'file1', size: 50, owner: 'user2', date: @date3 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 }
    ]

    sorted_files = @controller.sort_by_column(files, 'size', DirectoryUtilsConcern::ASCENDING)
    assert_equal [
      { name: 'file3', size: 25, owner: 'user2', date: @date2 },
      { name: 'file1', size: 50, owner: 'user2', date: @date3 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 },
      { name: 'file2', size: 100, owner: 'user1', date: @date1 }
    ], sorted_files
  end

  test 'sort_by_column sorts files by owner' do
    files = [
      { name: 'file3', size: 25, owner: 'user2', date: @date2 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 },
      { name: 'file2', size: 100, owner: 'user1', date: @date1 },
      { name: 'file1', size: 50, owner: 'user2', date: @date3 }
    ]

    sorted_files = @controller.sort_by_column(files, 'owner', DirectoryUtilsConcern::ASCENDING)
    assert_equal [
      { name: 'file2', size: 100, owner: 'user1', date: @date1 },
      { name: 'file3', size: 25, owner: 'user2', date: @date2 },
      { name: 'file1', size: 50, owner: 'user2', date: @date3 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 }
    ], sorted_files
  end

  test 'sort_by_column sorts files by date' do
    files = [
      { name: 'file3', size: 75, owner: 'user3', date: @date3 },
      { name: 'file4', size: 50, owner: 'user2', date: @date4 },
      { name: 'file2', size: 100, owner: 'user1', date: @date2 },
      { name: 'file1', size: 25, owner: 'user2', date: @date1 }
    ]

    sorted_files = @controller.sort_by_column(files, 'date', DirectoryUtilsConcern::ASCENDING)
    assert_equal [
      { name: 'file1', size: 25, owner: 'user2', date: @date1 },
      { name: 'file2', size: 100, owner: 'user1', date: @date2 },
      { name: 'file3', size: 75, owner: 'user3', date: @date3 },
      { name: 'file4', size: 50, owner: 'user2', date: @date4 }
    ], sorted_files
  end

  test 'sort_by_column sorts files by name' do
    files = [
      { name: 'file3', size: 25, owner: 'user2', date: @date1 },
      { name: 'file1', size: 50, owner: 'user2', date: @date3 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 },
      { name: 'file2', size: 100, owner: 'user1', date: @date2 }
    ]

    sorted_files = @controller.sort_by_column(files, 'name', DirectoryUtilsConcern::ASCENDING)
    assert_equal [
      { name: 'file1', size: 50, owner: 'user2', date: @date3 },
      { name: 'file2', size: 100, owner: 'user1', date: @date2 },
      { name: 'file3', size: 25, owner: 'user2', date: @date1 },
      { name: 'file4', size: 75, owner: 'user3', date: @date4 }
    ], sorted_files
  end

end