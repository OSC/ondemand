require 'application_system_test_case'
require 'rclone_helper'

class RemoteFilesTest < ApplicationSystemTestCase
  MAX_WAIT = 120

  def setup
    # we want to clear the console logs from any previous test.
    Capybara.current_session.quit
  end

  test "visiting files app doesn't raise js errors" do
    with_rclone_conf(Rails.root.to_s) do
      visit files_url('alias_remote', '/')
      messages = page.driver.browser.logs.get(:browser)
      content = messages.join("\n")
      assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"
    end
  end

  test 'visiting files app directory' do
    with_rclone_conf(Rails.root.to_s) do
      visit files_url('alias_remote', '/')
      find('tbody a', exact_text: 'app').ancestor('tr').find('input[type="checkbox"]').click
      assert_selector '.selected', count: 1
      find('tbody a', exact_text: 'config').ancestor('tr').find('input[type="checkbox"]').click
      assert_selector '.selected', count: 2

      visit files_url('local_remote', Rails.root.to_s)
      find('tbody a', exact_text: 'app').ancestor('tr').find('input[type="checkbox"]').click
      assert_selector '.selected', count: 1
      find('tbody a', exact_text: 'config').ancestor('tr').find('input[type="checkbox"]').click
      assert_selector '.selected', count: 2
    end
  end

  test 'adding new file' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        visit files_url('alias_remote', '/')
        find('#new-file-btn').click
        find('#files_input_modal_input').set('bar.txt')
        find('#files_input_modal_ok_button').click
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
        find('#files_input_modal_input').set('bar')
        find('#files_input_modal_ok_button').click
        find('tbody a[data-type="d"]', exact_text: 'bar', wait: MAX_WAIT)
        assert File.directory? File.join(dir, 'bar')

        visit files_url('local_remote', dir)
        find('tbody a[data-type="d"]', exact_text: 'bar', wait: MAX_WAIT)
      end
    end
  end

  test 'copying files' do
    visit files_url(Rails.root.to_s)
    %w(app config manifest.yml).each do |f|
      find('a', exact_text: f).ancestor('tr').find('input[type="checkbox"]').click
    end
    assert_selector '.selected', count: 3

    find('#copy-move-btn').click

    assert_selector '#clipboard li', count: 3

    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        visit files_url('alias_remote', '/bucket')

        # one row: No data available in table
        assert_selector '#directory-contents tbody tr', count: 1
        find('#clipboard-copy-to-dir').click

        # files are copying but it takes a little while
        find('tbody a', exact_text: 'config', wait: MAX_WAIT)
        find('tbody a', exact_text: 'manifest.yml', wait: MAX_WAIT)

        # with copying done, let's assert on the UI and the file system
        assert_selector 'span', text: '100% copy files', count: 1
        assert_equal '', `diff -rq #{File.join(dir, 'config')} #{Rails.root.join('config')}`.strip, 'failed to recursively copy config dir'
        assert_equal '', `diff -q #{File.join(dir, 'manifest.yml')} #{Rails.root.join('manifest.yml')}`.strip, 'failed to copy manifest.yml'

        sleep 6 # need to guarantee that this disappears after 5 seconds.
        assert_selector 'span', text: '100% copy files', count: 0
      end
    end
  end

  test 'rename file' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        FileUtils.touch File.join(dir, 'foo.txt')

        visit files_url('alias_remote', '/bucket')
        tr = find('a', exact_text: 'foo.txt').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        tr.find('.rename-file').click

        # rename dialog input
        find('#files_input_modal_input').set('bar.txt')
        find('#files_input_modal_ok_button').click

        find('tbody a', exact_text: 'bar.txt', wait: MAX_WAIT)
        assert File.file? File.join(dir, 'bar.txt')
      end
    end
  end

  test 'rename empty directory' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        Dir.mkdir(File.join(dir, 'foo'))

        visit files_url('alias_remote', '/bucket')
        tr = find('a', exact_text: 'foo').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        tr.find('.rename-file').click

        # rename dialog input
        find('#files_input_modal_input').set('bar')
        find('#files_input_modal_ok_button').click

        find('tbody a', exact_text: 'bar', wait: MAX_WAIT)
        assert File.directory? File.join(dir, 'bar')
      end
    end
  end

  test 'rename directory with files' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        Dir.mkdir(File.join(dir, 'foo'))
        FileUtils.touch File.join(dir, 'foo', 'foo.txt')

        visit files_url('alias_remote', '/bucket')
        tr = find('a', exact_text: 'foo').ancestor('tr')
        tr.find('button.dropdown-toggle').click
        tr.find('.rename-file').click

        # rename dialog input
        find('#files_input_modal_input').set('bar')
        find('#files_input_modal_ok_button').click

        find('tbody a', exact_text: 'bar', wait: MAX_WAIT)
        assert File.directory? File.join(dir, 'bar')
        assert File.file? File.join(dir, 'bar', 'foo.txt')
      end
    end
  end

  test 'moving files' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        # copy to dest/app
        dest = File.join(dir, 'dest')
        FileUtils.mkpath dest

        `cp -r #{Rails.root.join('app')} #{Rails.root.join('config')}  #{Rails.root.join('manifest.yml')} #{dir}`

        # select dir to move
        visit files_url('alias_remote', '/bucket')
        %w(app config manifest.yml).each do |f|
          find('a', exact_text: f).ancestor('tr').find('input[type="checkbox"]').click
        end
        assert_selector '.selected', count: 3

        find('#copy-move-btn').click

        # move to new location
        visit files_url('alias_remote', '/bucket/dest')
        find('#clipboard-move-to-dir').click
        find('tbody a', exact_text: 'app', wait: MAX_WAIT)
        find('tbody a', exact_text: 'config', wait: MAX_WAIT)
        find('tbody a', exact_text: 'manifest.yml', wait: MAX_WAIT)

        # verify contents moved
        assert_equal '', `diff -rq #{File.join(dest, 'app')} #{Rails.root.join('app')}`.strip, 'failed to mv app and all contents'
        assert_equal '', `diff -rq #{File.join(dest, 'config')} #{Rails.root.join('config')}`.strip, 'failed to recursively copy config dir'
        assert_equal '', `diff -q #{File.join(dest, 'manifest.yml')} #{Rails.root.join('manifest.yml')}`.strip, 'failed to copy manifest.yml'

        # verify original does not exist
        refute File.directory?(File.join(dir, 'app'))
        refute File.directory?(File.join(dir, 'config'))
        refute File.directory?(File.join(dir, 'manifest.yml'))
      end
    end
  end

  # Using files move test to specifically test that RcloneUtil.rclone_popen works
  test 'moving files with remote configured in extra config' do
    Dir.mktmpdir do |dir|
      with_extra_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        # copy to dest/app
        dest = File.join(dir, 'dest')
        FileUtils.mkpath dest

        `cp -r #{Rails.root.join('app')} #{Rails.root.join('config')}  #{Rails.root.join('manifest.yml')} #{dir}`

        # select dir to move
        visit files_url('extra_remote', dir)
        %w(app config manifest.yml).each do |f|
          find('a', exact_text: f).ancestor('tr').find('input[type="checkbox"]').click
        end
        assert_selector '.selected', count: 3

        find('#copy-move-btn').click

        # move to new location
        visit files_url('extra_remote', "#{dir}/dest")
        find('#clipboard-move-to-dir').click
        find('tbody a', exact_text: 'app', wait: MAX_WAIT)
        find('tbody a', exact_text: 'config', wait: MAX_WAIT)
        find('tbody a', exact_text: 'manifest.yml', wait: MAX_WAIT)

        # verify contents moved
        assert_equal '', `diff -rq #{File.join(dest, 'app')} #{Rails.root.join('app')}`.strip, 'failed to mv app and all contents'
        assert_equal '', `diff -rq #{File.join(dest, 'config')} #{Rails.root.join('config')}`.strip, 'failed to recursively copy config dir'
        assert_equal '', `diff -q #{File.join(dest, 'manifest.yml')} #{Rails.root.join('manifest.yml')}`.strip, 'failed to copy manifest.yml'

        # verify original does not exist
        refute File.directory?(File.join(dir, 'app'))
        refute File.directory?(File.join(dir, 'config'))
        refute File.directory?(File.join(dir, 'manifest.yml'))
      end
    end
  end

  test 'removing files' do
    Dir.mktmpdir do |dir|
      with_rclone_conf(dir) do
        # Test in a subdir of the temp directory
        dir = File.join(dir, 'bucket')
        Dir.mkdir(dir)

        # copy to dest/app
        src = File.join(dir, 'app')
        `cp -r #{Rails.root.join('app')} #{src}`
        FileUtils.touch(File.join(dir, 'foo.txt'))

        # select dir to move
        visit files_url('alias_remote', '/bucket')
        find('a', exact_text: 'app').ancestor('tr').find('input[type="checkbox"]').click
        find('a', exact_text: 'foo.txt').ancestor('tr').find('input[type="checkbox"]').click
        find('#delete-btn').click
        find('#files_input_modal_ok_button').click

        # Allow time for file to be removed
        sleep 1

        # verify app dir deleted according to UI
        assert_no_selector 'tbody a', exact_text: 'app', wait: 10
        assert_no_selector 'tbody a', exact_text: 'foo.txt', wait: 10

        # verify app dir actually deleted
        refute File.exist?(src)
        refute File.exist?(File.join(dir, 'foo.txt'))
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
        sleep 1
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
      find('#files_input_modal_input').set('/app')
      find('#files_input_modal_ok_button').click
      find('tbody a', exact_text: 'helpers')
      find('tbody a', exact_text: 'controllers')

      find('#goto-btn').click
      find('#files_input_modal_input').set('/')
      find('#files_input_modal_ok_button').click
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

          find('#save-button').click
        end

        sleep 1 # FIXME: should avoid using sleep here
        assert_equal 'foobar', File.read(file)
      end
    end
  end
end
