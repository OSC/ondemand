require 'test_helper'

class BatchConnect::SettingsHelperTest < ActionView::TestCase

  include BatchConnect::SettingsHelper

  test 'all_saved_settings should return stored saved settings' do
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/settings_helper.yml"
    Configuration.stubs(:user_settings_file).returns(file)
    result = all_saved_settings
    assert_equal 2, result.size

    assert_equal 'sys/bc_paraview', result[0].token
    assert_equal 'account cpu', result[0].name
    assert_equal 'cpu', result[0].values[:cluster]
    assert_equal '1', result[0].values[:bc_num_hours]
    assert_equal 'helper_cpu', result[0].values[:bc_account]
    assert_equal '1080x800', result[0].values[:bc_vnc_resolution]

    assert_equal 'sys/bc_paraview', result[1].token
    assert_equal 'account memory', result[1].name
    assert_equal 'memory', result[1].values[:cluster]
    assert_equal '10', result[1].values[:bc_num_hours]
    assert_equal 'helper_memory', result[1].values[:bc_account]
    assert_equal '800x600', result[1].values[:bc_vnc_resolution]
  end
end