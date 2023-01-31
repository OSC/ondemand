# frozen_string_literal: true

require 'test_helper'

class RecentlyUsedAppsHelperTest < ActionView::TestCase
  include RecentlyUsedAppsHelper

  def setup
    # Mock ApplicationController setting default values to the apps
    @sys_apps = []
    @dev_apps = []
    @usr_apps = []
  end

  test 'recently_used_apps should return empty array when cache_root directory has no files' do
    BatchConnect::Session.stubs({ cache_root: stub({ children: [] }) })
    result = recently_used_apps

    assert_equal [], result
  end

  test 'recently_used_apps should return empty array when cache files do not match any application' do
    cache_files = create_cache_files(['rstudio.json', 'jupyter.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files }) })
    @sys_apps = create_batch_connect_apps(['no_match.json', 'other.json'])

    result = recently_used_apps

    assert_equal [], result
  end

  test 'recently_used_apps should ignore applications that are not batch_connect' do
    cache_files = create_cache_files(['rstudio.json', 'batch_connect.json', 'jupyter.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['rstudio.json', 'jupyter.json'], batch_connect: false) + create_batch_connect_apps(['batch_connect.json'])

    result = recently_used_apps

    assert_equal 1, result.size
    assert_equal 'batch_connect.json', result[0].cache_file
  end

  test 'recently_used_apps should ignore applications that are not valid' do
    cache_files = create_cache_files(['rstudio.json', 'valid.json', 'jupyter.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['rstudio.json', 'jupyter.json'], valid: false) + create_batch_connect_apps(['valid.json'])

    result = recently_used_apps

    assert_equal 1, result.size
    assert_equal 'valid.json', result[0].cache_file
  end

  test 'recently_used_apps should return the applications that matches the cache files' do
    cache_files = create_cache_files(['rstudio.json', 'jupyter.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['no_match.json', 'rstudio.json'])

    result = recently_used_apps

    assert_equal 1, result.size
    assert_equal 'rstudio.json', result[0].cache_file
  end

  test 'recently_used_apps should set cacheable attribute to matched sys apps to true' do
    cache_files = create_cache_files(['rstudio.json', 'jupyter.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['jupyter.json', 'rstudio.json'])

    result = recently_used_apps

    assert_equal 2, result.size
    result.each do |app|
      app.build_session_context.each do |attribute|
        assert_equal true, attribute.cacheable?(false)
      end
    end
  end

  test 'recently_used_apps should return at most 4 apps sorted by most recent cache files' do
    cache_files = create_cache_files(
      ['ancient.json',
       'very_old.json',
       'old.json',
       'now.json',
       'newer.json',
       'newest.json']
    )
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['newer.json', 'very_old.json', 'now.json', 'ancient.json', 'newest.json', 'old.json'])

    result = recently_used_apps

    assert_equal 4, result.size
    assert_equal 'newest.json', result[0].cache_file
    assert_equal 'newer.json', result[1].cache_file
    assert_equal 'now.json', result[2].cache_file
    assert_equal 'old.json', result[3].cache_file
  end

  test 'recently_used_apps should call update_session_with_cache in all matched applications' do
    cache_files = create_cache_files(['rstudio.json', 'jupyter.json', 'desktop.json'])
    BatchConnect::Session.stubs({ cache_root: stub({ children: cache_files, join: nil }) })
    @sys_apps = create_batch_connect_apps(['rstudio.json', 'jupyter.json', 'desktop.json'])
    @sys_apps.each { |app| app.expects(:update_session_with_cache) }

    result = recently_used_apps

    assert_equal 3, result.size
  end

  test 'recently_used_apps_cached should should call Rails.cache with a block' do
    BatchConnect::Session.stubs({ cache_root: stub({ children: [] }) })
    Rails.cache.expects(:fetch).with('recently_used_apps', expires_in: 1.hour).with_block_given.returns([])
    result = recently_used_apps

    assert_equal [], result
  end

  def create_cache_files(files)
    files.each_with_index.map do |filename, index|
      Pathname.new(filename).tap { |pathname| File.stubs(:mtime).with(pathname).returns(Time.now + index.day) }
    end
  end

  def create_batch_connect_apps(files, batch_connect: true, valid: true)
    attributes = files.map { |filename| SmartAttributes::Attribute.new(filename, { cacheable: false }) }
    files.map do |filename|
      BatchConnectAppMock.new.tap do |sys_app|
        sys_app.send('batch_connect_app?=', batch_connect)
        sys_app.send('valid?=', valid)
        sys_app.cache_file = filename
        sys_app.sub_app_list = [sys_app]
        sys_app.build_session_context = BatchConnect::SessionContext.new(attributes)
      end
    end
  end

  private

  class BatchConnectAppMock < OpenStruct
    def update_session_with_cache(session_context, cache_file)
      # Just stubbing the method
    end
  end
end
