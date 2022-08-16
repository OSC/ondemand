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

  test "uploading files" do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        FileUtils.mkpath File.join(dir, 'foo')

        visit files_url('alias_remote', '/')
        find('#upload-btn').click

        find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

        src_file = 'test/fixtures/files/upload/osc-logo.png'
        attach_file 'files[]', src_file, visible: false, match: :first
        find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
        find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)

        find('tbody a', exact_text: 'foo').click
        # Need to wait until we're in the new directory before clicking upload
        assert_no_selector 'tbody a', exact_text: 'foo', wait: MAX_WAIT

        find('#upload-btn').click
        find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

        src_file = 'test/fixtures/files/upload/hello-world.c'
        attach_file 'files[]', src_file, visible: false, match: :first
        find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
        find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)
      end
    end
  end

  test "changing directory" do
    with_rclone_conf(Rails.root.to_s) do
      visit files_url('alias_remote', '/')

      find('tbody a', exact_text: 'app')
      find('tbody a', exact_text: 'config')

      find('#goto-btn').click
      find('#swal2-input').set('/app')
      find('.swal2-confirm').click
      find('tbody a', exact_text: 'helpers')
      find('tbody a', exact_text: 'controllers')

      find('#goto-btn').click
      find('#swal2-input').set('/')
      find('.swal2-confirm').click
      find('tbody a', exact_text: 'app')
      find('tbody a', exact_text: 'config')
    end
  end

  test "edit file" do
    OodAppkit.stubs(:files).returns(OodAppkit::Urls::Files.new(title: 'Files', base_url: '/files'))
    OodAppkit.stubs(:editor).returns(OodAppkit::Urls::Editor.new(title: 'Editor', base_url: '/files'))

    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        file = File.join(dir, 'foo.txt')
        FileUtils.touch file

        visit files_url('alias_remote', '/')

        tr = find('a', exact_text: File.basename(file)).ancestor('tr')
        tr.find('button.dropdown-toggle').click
        edit_window = window_opened_by { tr.find('.edit-file').click }

        within_window edit_window do
          find('#editor').click
          find('textarea.ace_text-input', visible: false).send_keys 'foobar'

          find('.navbar-toggler').click
          find('#save-button').click
        end

        sleep 1 # FIXME: should avoid using sleep here
        assert_equal 'foobar', File.read(file)
      end
    end
  end
end
