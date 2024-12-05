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

  test 'validate_path! calls AllowlistPolicy when posix_file?' do
    @controller.stubs(:posix_file?).returns(true)
    @controller.instance_variable_set(:@path, mock('PosixFile'))
    AllowlistPolicy.default.expects(:validate!).with(@controller.instance_variable_get(:@path))

    @controller.validate_path!
  end

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

  test 'set_sorting_params sets @sorting_params correctly with valid parameters' do
    parameters = { col: 'name', direction: DirectoryUtilsConcern::ASCENDING, grouped?: true }
    @controller.set_sorting_params(parameters)
    expected_params = { col: 'name', direction: DirectoryUtilsConcern::ASCENDING, grouped?: true }
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

  test 'set_sorting_params sets @sorting_params with empty  parameters' do
    parameters = {}
    @controller.set_sorting_params(parameters)
    expected_params = { col: "name", direction: true, grouped?: true }
    assert_equal expected_params, @controller.instance_variable_get(:@sorting_params)
  end


end