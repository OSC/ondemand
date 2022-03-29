# frozen_string_literal: true

require 'test_helper'

class HpcModuleTest < ActiveSupport::TestCase

  # owens.json and oakley.json in this directory are from real clusters
  # (oakley is actually pitzer) from the time this was written.
  def fixture_dir
    "#{Rails.root}/test/fixtures/modules/"
  end

  test 'all safely reads from inaccessabile directories' do
    with_modified_env({ OOD_MODULE_FILE_DIR: '/dev/null' }) do
      assert_equal [], HpcModule.all('owens')
    end
  end

  test 'all safely reads invalid json' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_MODULE_FILE_DIR: dir }) do
        `echo '{this is bad json}' > #{dir}/owens.json`
        assert_equal [], HpcModule.all('owens')
      end
    end
  end

  test 'reads a simple file' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      # NOTE: that there are no duplicates and rstudio has no version
      assert_equal(['jupyter/1', 'jupyter/2', 'rstudio'], HpcModule.all('simple').map(&:to_s))
    end
  end

  test 'all versions is corrrect, sorted and unique' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      expected = [
        'app_jupyter/3.1.18', 'app_jupyter/3.0.17', 'app_jupyter/2.3.2', 'app_jupyter/2.2.10',
        'app_jupyter/1.2.21', 'app_jupyter/1.2.16', 'app_jupyter/0.35.6'
      ]
      assert_equal(expected, HpcModule.all_versions('app_jupyter').map(&:to_s))
    end
  end

  test 'all versions returns empty array when it cant find' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      assert_equal([], HpcModule.all_versions('wont_find').map(&:to_s))
      assert_equal([], HpcModule.all_versions(nil).map(&:to_s))
    end
  end

  test 'on_cluster? can find modules' do
    stub_sys_apps
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      assert HpcModule.new('app_jupyter', version: '0.35.6').on_cluster?('oakley')
      assert !HpcModule.new('app_jupyter', version: '0.35.6').on_cluster?('owens')
    end
  end

  test 'default version' do
    m = HpcModule.new('test')
    assert m.default?
    assert m.version.nil?
  end

  test 'module with version version' do
    m = HpcModule.new('test', version: 9001)
    assert !m.default?
    assert_equal m.version, '9001' # we gave an int, got back a string
  end
end
