require "application_system_test_case"

class FilesTest < ApplicationSystemTestCase

  MAX_WAIT = 120

  test "visiting files app doesn't raise js errors" do
    visit files_url(Rails.root.to_s)

    messages = page.driver.browser.logs.get(:browser)
    content = messages.join("\n")
    assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"
  end

  test "visiting files app directory" do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app').ancestor('tr').click
    assert_selector '.selected', count: 1
    find('tbody a', exact_text: 'config').ancestor('tr').click(:meta)
    assert_selector '.selected', count: 2
  end

  test "adding new file" do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-file-btn').click
      find('#swal2-input').set('bar.txt')
      find('.swal2-confirm').click
      find('tbody a', exact_text: 'bar.txt', wait: MAX_WAIT)
      assert File.file? File.join(dir, 'bar.txt')
    end
  end

  test "adding a new directory" do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-dir-btn').click
      find('#swal2-input').set('bar')
      find('.swal2-confirm').click
      find('tbody a.d', exact_text: 'bar', wait: MAX_WAIT)
      assert File.directory? File.join(dir, 'bar')
    end
  end

  test "copying files" do
    visit files_url(Rails.root.to_s)
    %w(app config manifest.yml).each do |f|
      find('a', exact_text: f).ancestor('tr').click(:meta)
    end
    assert_selector '.selected', count: 3

    find('#copy-move-btn').click

    assert_selector '#clipboard li', count: 3

    Dir.mktmpdir do |dir|
      visit files_url(dir)

      # one row: No data available in table
      assert_selector '#directory-contents tbody tr', count: 1
      find('#clipboard-copy-to-dir').click

      # files are copying but it takes a little while
      find('tbody a', exact_text: 'app', wait: MAX_WAIT)
      find('tbody a', exact_text: 'config', wait: MAX_WAIT)
      find('tbody a', exact_text: 'manifest.yml', wait: MAX_WAIT)

      # with copying done, let's assert on the UI and the file system
      assert_selector 'span', text: '100% copy files', count: 1
      assert_equal "", `diff -rq #{File.join(dir, 'app')} #{Rails.root.join('app').to_s}`.strip, "failed to recursively copy app dir"
      assert_equal "", `diff -rq #{File.join(dir, 'config')} #{Rails.root.join('config').to_s}`.strip, "failed to recursively copy config dir"
      assert_equal "", `diff -q #{File.join(dir, 'manifest.yml')} #{Rails.root.join('manifest.yml').to_s}`.strip, "failed to copy manifest.yml"

      sleep 6 # need to guarantee that this disappears after 5 seconds.
      assert_selector 'span', text: '100% copy files', count: 0
    end
  end

  test "rename file" do
    Dir.mktmpdir do |dir|
      FileUtils.touch File.join(dir, 'foo.txt')

      visit files_url(dir)
      tr = find('a', exact_text: 'foo.txt').ancestor('tr')
      tr.find('button.dropdown-toggle').click
      tr.find('.rename-file').click

      # rename dialog input
      find('#swal2-input').set('bar.txt')
      find('.swal2-confirm').click

      find('tbody a', exact_text: 'bar.txt', wait: MAX_WAIT)
      assert File.file? File.join(dir, 'bar.txt')
    end
  end

  test "moving files" do
    Dir.mktmpdir do |dir|
      # copy to dest/app
      src = File.join(dir, 'app')
      dest = File.join(dir, 'dest')
      FileUtils.mkpath dest

      `cp -r #{Rails.root.join('app').to_s} #{src}`


      # select dir to move
      visit files_url(dir)
      find('tbody a', exact_text: 'app').ancestor('tr').click
      find('#copy-move-btn').click

      # move to new location
      visit files_url(dest)
      find('#clipboard-move-to-dir').click
      find('tbody a', exact_text: 'app', wait: MAX_WAIT)

      # verify contents moved
      assert_equal "", `diff -rq #{File.join(dest, 'app')} #{Rails.root.join('app').to_s}`.strip, "failed to mv app and all contents"

      # verify original does not exist
      refute File.directory?(src)
    end
  end

  test "removing files" do
    Dir.mktmpdir do |dir|
      # copy to dest/app
      src = File.join(dir, 'app')
      `cp -r #{Rails.root.join('app').to_s} #{src}`

      # select dir to move
      visit files_url(dir)
      find('tbody a', exact_text: 'app').ancestor('tr').click
      find('#delete-btn').click
      find('button.swal2-confirm').click

      # verify app dir deleted according to UI
      assert_no_selector 'tbody a', exact_text: 'app', wait: 10

      # verify app dir actually deleted
      refute File.exist?(src)
    end
  end

  test "uploading files" do
    Dir.mktmpdir do |dir|

      FileUtils.mkpath File.join(dir, 'foo')

      visit files_url(dir)
      find('#upload-btn').click

      find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

      src_file = 'test/fixtures/files/upload/osc-logo.png'
      attach_file 'files[]', src_file, visible: false, match: :first
      find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
      find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)
      assert File.exist?(File.join(dir, File.basename(src_file)))

      find('tbody a', exact_text: 'foo').click
      # Need to wait until we're in the new directory before clicking upload
      assert_no_selector 'tbody a', exact_text: 'foo', wait: MAX_WAIT

      find('#upload-btn').click
      find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

      src_file = 'test/fixtures/files/upload/hello-world.c'
      attach_file 'files[]', src_file, visible: false, match: :first
      find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
      find('tbody a', exact_text: 'hello-world.c', wait: MAX_WAIT)
    end
  end

  test 'uploading duplicate files' do
    Dir.mktmpdir do |dir|
      upload_dir = File.join(dir, 'upload')
      FileUtils.mkpath(upload_dir)

      src_file = "#{dir}/testfile.sh"
      upload_file = "#{upload_dir}/testfile.sh"
      `echo 'here some initial content' > #{src_file}`

      visit files_url(upload_dir)
      find('#upload-btn').click
      find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

      attach_file 'files[]', src_file, visible: false, match: :first
      find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
      find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)
      assert File.exist?(upload_file)
      assert_equal File.read(src_file), File.read(upload_file)
      assert_equal File.stat(upload_file).mode, 33_188 # default 644

      # now change the permissions and verify
      `chmod 755 #{upload_file}`
      assert_equal File.stat(upload_file).mode, 33_261 # now 755

      # add something more to the original file
      `echo 'and some more content' >> #{src_file}`

      # upload the file again
      find('#upload-btn').click
      find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)
      attach_file 'files[]', src_file, visible: false, match: :first
      find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
      find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)

      # and it's still there, now with new content and it keesp the 755 permissions
      assert File.exist?(upload_file)
      assert_equal File.read(src_file), File.read(upload_file)
      assert_equal File.stat(upload_file).mode, 33_261 # still 755
    end
  end

  test "changing directory" do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app')
    find('tbody a', exact_text: 'config')

    find('#goto-btn').click
    find('#swal2-input').set(Rails.root.join("app"))
    find('.swal2-confirm').click
    find('tbody a', exact_text: 'helpers')
    find('tbody a', exact_text: 'controllers')

    find('#goto-btn').click
    find('#swal2-input').set(Rails.root.to_s)
    find('.swal2-confirm').click
    find('tbody a', exact_text: 'app')
    find('tbody a', exact_text: 'config')
  end

  test "edit file" do
    OodAppkit.stubs(:files).returns(OodAppkit::Urls::Files.new(title: 'Files', base_url: '/files'))
    OodAppkit.stubs(:editor).returns(OodAppkit::Urls::Editor.new(title: 'Editor', base_url: '/files'))

    Dir.mktmpdir do |dir|
      file = File.join(dir, 'foo.txt')
      FileUtils.touch file

      visit files_url(dir)

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

  test 'uppy localization' do
    with_modified_env(FILE_UPLOAD_MAX: '10') do
      Dir.mktmpdir do |dir|
        # No localization (default)
        visit files_url(dir)
        find('#upload-btn').click
        find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

        src_file = 'test/fixtures/files/upload/osc-logo.png'
        attach_file 'files[]', src_file, visible: false, match: :first

        find('.uppy.uppy-Informer', text: /osc-logo.png exceeds [\w ]+ size of 10 B/, wait: MAX_WAIT)

        # Temporarily add localization for max upload size error
        en = { :dashboard => { :uppy => { :strings => { :exceedsSize => 'custom error, %{file}, %{size}' } } } }
        I18n.backend.store_translations(:en, en)

        visit files_url(dir)
        find('#upload-btn').click
        find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)

        src_file = 'test/fixtures/files/upload/osc-logo.png'
        attach_file 'files[]', src_file, visible: false, match: :first

        find('.uppy.uppy-Informer', text: 'custom error, osc-logo.png, 10 B', wait: MAX_WAIT)

        I18n.backend.reload!
        # Clear browser logs
        page.driver.browser.logs.get(:browser)
      end
    end
  end

  test 'symlinked directories' do
    Dir.mktmpdir do |dir|
      `cd #{dir}; mkdir -p #{dir} real_dir`
      `cd #{dir}; touch #{dir} real_dir/real_file`
      `cd #{dir}; ln -s real_dir linked_dir`

      visit files_url(dir)

      find('tbody a', exact_text: 'real_dir')
      find('tbody a', exact_text: 'linked_dir')
      assert_selector('tbody span[title="directory"]', count: 2)

      # click the symlink
      find('tbody a', exact_text: 'linked_dir').click

      find('tbody a', exact_text: 'real_file', wait: MAX_WAIT)
      assert_selector('tbody span[title="file"]', count: 1)
    end
  end
end
