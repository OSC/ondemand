require 'application_system_test_case'
require 'rclone_helper'

class RemoteFilesTest < ApplicationSystemTestCase
  MAX_WAIT = 120

  test "visiting files app doesn't raise js errors" do
    with_rclone_conf(Rails.root.to_s) do
      visit files_url('alias_remote', '/')
      messages = page.driver.browser.manage.logs.get(:browser)
      content = messages.join("\n")
      assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"
    end
  end

  test 'visiting files app directory' do
    with_rclone_conf(Rails.root.to_s) do
      visit files_url('alias_remote', '/')
      find('tbody a', exact_text: 'app').ancestor('tr').click
      assert_selector '.selected', count: 1
      find('tbody a', exact_text: 'config').ancestor('tr').click(:meta)
      assert_selector '.selected', count: 2

      visit files_url('local_remote', Rails.root.to_s)
      find('tbody a', exact_text: 'app').ancestor('tr').click
      assert_selector '.selected', count: 1
      find('tbody a', exact_text: 'config').ancestor('tr').click(:meta)
      assert_selector '.selected', count: 2
    end
  end

  test 'adding new file' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        visit files_url('alias_remote', '/')
        find('#new-file-btn').click
        find('#swal2-input').set('bar.txt')
        find('.swal2-confirm').click
        find('tbody a', exact_text: 'bar.txt', wait: MAX_WAIT)
        assert File.file? File.join(dir, 'bar.txt')
      end
    end
  end

  test 'adding a new directory' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        visit files_url('alias_remote', '/')
        find('#new-dir-btn').click
        find('#swal2-input').set('bar')
        find('.swal2-confirm').click
        find('tbody a.d', exact_text: 'bar', wait: MAX_WAIT)
        assert File.directory? File.join(dir, 'bar')

        visit files_url('local_remote', dir)
        find('tbody a.d', exact_text: 'bar', wait: MAX_WAIT)
      end
    end
  end
end
