# frozen_string_literal: true

require 'test_helper'

class UserSettingStoreTest < ActionView::TestCase
  include UserSettingStore

  def setup
    @user_settings = nil
  end

  test 'user_settings cannot be modified' do
    current_settings = user_settings
    current_settings[:profile] = 'new value'

    refute_equal current_settings, user_settings
    refute_equal current_settings[:profile], user_settings[:profile]
  end

  test 'read_user_settings should read data from user settings file' do
    Configuration.stubs(:user_settings_file).returns("#{Rails.root}/test/fixtures/config/user_settings/.valid")
    expected_user_settings = { :profile=>'file_value' }

    assert_equal expected_user_settings, read_user_settings
  end

  test 'read_user_settings should log errors when reading settings from file' do
    Configuration.stubs(:user_settings_file).returns("#{Rails.root}/test/fixtures/config/user_settings/.invalid")
    Rails.logger.expects(:error).with(regexp_matches(/Can't read or parse settings file/)).at_least_once
    expected_user_settings = {}

    assert_equal expected_user_settings, read_user_settings
  end

  test 'update_user_settings should create data directory when is not available' do
    with_user_settings_file('update_test') do
      data_root = Pathname.new(File.dirname(Configuration.user_settings_file))
      assert_equal false, data_root.exist?

      update_user_settings({})

      assert_equal true, data_root.exist?
    end
  end

  test 'update_user_settings should update internal data and user settings file' do
    with_user_settings_file do
      settings = user_settings
      settings[:profile] = 'profile_value'
      update_user_settings(settings)

      assert_equal settings, user_settings
      assert_equal settings, YAML.safe_load(File.read(user_settings_path)).deep_symbolize_keys
    end
  end

  test 'all_bc_templates returns empty hash when there is no data' do
    with_user_settings_file do
      assert_equal({}, all_bc_templates)
    end
  end

  test 'bc_templates returns empty hash when there is no data' do
    with_user_settings_file do
      assert_equal({}, bc_templates('app/token'))
    end
  end

  test 'bc_templates returns application saved settings' do
    with_user_settings_file do
      app = sys_bc_app
      values = { name1: 'value1', name2: 'value2' }

      save_bc_template(app, 'settings1', values)
      save_bc_template(app, 'settings2', values)
      assert_equal({ settings1: values, settings2: values }, bc_templates(app))
    end
  end

  test 'save_bc_template save settings with expected structure' do
    with_user_settings_file do
      app = sys_bc_app
      values = { name1: 'value1', name2: 'value2' }

      save_bc_template(app, 'settings1', values)
      save_bc_template(app, 'settings2', values)
      assert_equal({ app.token.to_sym => { settings1: values, settings2: values } }, all_bc_templates)
    end
  end

  test 'delete_bc_template deletes settings data' do
    with_user_settings_file do
      assert_equal({}, all_bc_templates)
      app = sys_bc_app
      values = { name1: 'value1', name2: 'value2' }

      save_bc_template(app, 'settings1', values)
      save_bc_template(app, 'settings2', values)
      assert_equal({ app.token.to_sym => { settings1: values, settings2: values } }, all_bc_templates)

      delete_bc_template(app.token, 'settings1')
      assert_equal({ app.token.to_sym => { settings2: values } }, all_bc_templates)
    end
  end

  test 'delete_bc_template deletes app entry when empty' do
    with_user_settings_file do
      assert_equal({}, all_bc_templates)
      app = sys_bc_app
      values = { name1: 'value1', name2: 'value2' }

      save_bc_template(app, 'settings name', values)
      assert_equal({ app.token.to_sym => { :'settings name' => values } }, all_bc_templates)

      delete_bc_template(app.token, 'settings name')
      assert_equal({}, all_bc_templates)
    end
  end

  private

  def with_user_settings_file(sub_folder = nil)
    Dir.mktmpdir do |temp_data_dir|
      path_parts = [temp_data_dir, sub_folder, 'settings.yml'].compact
      Configuration.stubs(:user_settings_file).returns(File.join(path_parts))

      yield if block_given?

    end
  end

end
