# frozen_string_literal: true

require 'test_helper'

class CurrentUserTest < ActiveSupport::TestCase
  test 'aliases from Etc work' do
    pwuid = Etc.getpwuid
    assert_equal pwuid.gid, CurrentUser.gid
    assert_equal pwuid.uid, CurrentUser.uid
    assert_equal pwuid.dir, CurrentUser.dir
    assert_equal pwuid.dir, CurrentUser.home
    assert_equal pwuid.name, CurrentUser.name
    assert_equal pwuid.gecos, CurrentUser.gecos
    assert_equal pwuid.shell, CurrentUser.shell
  end

  test 'primary group is correct' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.gid
    assert_equal Etc.getgrgid(gid), CurrentUser.primary_group
  end

  test 'primary group name is correct' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.gid
    assert_equal Etc.getgrgid(gid).name, CurrentUser.primary_group_name
  end

  test 'user_settings cannot be modified' do
    current_settings = CurrentUser.user_settings
    current_settings[:profile] = 'new value'

    refute_equal current_settings, CurrentUser.user_settings
  end

  test 'read_user_settings should read data from user settings file' do
    with_modified_env(OOD_DATAROOT:           "#{Rails.root}/test/fixtures/config/user_settings",
                      OOD_USER_SETTINGS_FILE: '.valid') do
      expected_user_settings = { :profile=>'file_value' }

      assert_equal expected_user_settings, CurrentUser.instance.send(:read_user_settings)
    end
  end

  test 'read_user_settings should log errors when reading settings from file' do
    with_modified_env(OOD_DATAROOT:           "#{Rails.root}/test/fixtures/config/user_settings",
                      OOD_USER_SETTINGS_FILE: '.invalid') do
      Rails.logger.expects(:error).with(regexp_matches(/Can't read or parse settings file/)).at_least_once
      expected_user_settings = {}

      assert_equal expected_user_settings, CurrentUser.instance.send(:read_user_settings)
    end
  end

  test 'update_user_settings should create data directory when is not available' do
    Dir.mktmpdir do |temp_data_dir|
      data_root = Pathname.new(temp_data_dir).join('update_test')
      assert_equal false, data_root.exist?

      Configuration.stubs(:dataroot).returns(data_root.to_s)

      CurrentUser.update_user_settings({})

      assert_equal true, data_root.exist?
    end
  end

  test 'update_user_settings should update internal data and user settings file' do
    Dir.mktmpdir do |temp_data_dir|
      Configuration.stubs(:dataroot).returns(temp_data_dir)

      settings = CurrentUser.user_settings
      settings[:profile] = 'profile_value'
      CurrentUser.update_user_settings(settings)

      assert_equal settings, CurrentUser.user_settings
      assert_equal settings,
                   YAML.safe_load(File.read(CurrentUser.instance.send(:user_settings_path))).deep_symbolize_keys
    end
  end

  test 'primary group is first in groups' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.groups.first.gid
  end

  test 'groups is the same as process.groups' do
    assert_equal Process.groups.to_set, CurrentUser.groups.map(&:gid).to_set
  end
end
