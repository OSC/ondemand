# frozen_string_literal: true

require 'application_system_test_case'

class FilesTest < ApplicationSystemTestCase
  MAX_WAIT = 120

  def setup
    FileUtils.rm_rf(DOWNLOAD_DIRECTORY.to_s)
    FileUtils.mkdir_p(DOWNLOAD_DIRECTORY.to_s)

    # we want to clear the console logs from any previous test.
    Capybara.current_session.quit
  end

  test "visiting files app doesn't raise js errors" do
    visit files_url(Rails.root.to_s)

    messages = page.driver.browser.logs.get(:browser)
    content = messages.join("\n")
    assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"
  end

  test 'visiting files app directory' do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app').ancestor('tr').find('input[type="checkbox"]').click
    assert_selector '.selected', count: 1
    find('tbody a', exact_text: 'config').ancestor('tr').find('input[type="checkbox"]').click
    assert_selector '.selected', count: 2
  end

  test 'adding new file' do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-file-btn').click
      find('#files_input_modal_input').set('bar.txt')
      find('#files_input_modal_ok_button').click
      find('tbody a', exact_text: 'bar.txt', wait: MAX_WAIT)
      assert File.file? File.join(dir, 'bar.txt')
    end
  end

  test 'adding a new directory' do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-dir-btn').click
      find('#files_input_modal_input').set('bar')
      find('#files_input_modal_ok_button').click
      find('tbody a[data-type="d"]', exact_text: 'bar', wait: MAX_WAIT)
      assert File.directory? File.join(dir, 'bar')
    end
  end

  test 'copying files' do
    visit files_url(Rails.root.to_s)
    ['app', 'config', 'manifest.yml'].each do |f|
      find('a', exact_text: f).ancestor('tr').find('input[type="checkbox"]').click
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
      assert_equal '', `diff -rq #{File.join(dir, 'app')} #{Rails.root.join('app')}`.strip,
                   'failed to recursively copy app dir'
      assert_equal '', `diff -rq #{File.join(dir, 'config')} #{Rails.root.join('config')}`.strip,
                   'failed to recursively copy config dir'
      assert_equal '', `diff -q #{File.join(dir, 'manifest.yml')} #{Rails.root.join('manifest.yml')}`.strip,
                   'failed to copy manifest.yml'

      sleep 6 # need to guarantee that this disappears after 5 seconds.
      assert_selector 'span', text: '100% copy files', count: 0
    end
  end

  test 'copying empty directories' do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(["#{dir}/src", "#{dir}/dest"])
      FileUtils.mkdir_p("#{dir}/src/dir/one/two")

      visit files_url(dir)
      find('tbody a', exact_text: 'src').ancestor('tr').click

      find('#copy-move-btn').click
      visit files_url("#{dir}/dest")
      find('#clipboard-copy-to-dir').click

      # now step through all the empty directories and see they're there.
      visit files_url("#{dir}/dest")
      find('tbody a', exact_text: 'src', wait: MAX_WAIT)

      visit files_url("#{dir}/dest/src")
      find('tbody a', exact_text: 'dir')

      visit files_url("#{dir}/dest/src/dir")
      find('tbody a', exact_text: 'one')

      visit files_url("#{dir}/dest/src/dir/one")
      find('tbody a', exact_text: 'two')

      visit files_url("#{dir}/dest/src/dir/one/two")
      # one row: No data available in table
      assert_selector('#directory-contents tbody tr', count: 1)

      # just to be sure, check the actual file system
      dest = Pathname.new("#{dir}/dest/src/dir/one/two")
      assert(dest.exist?)
      assert(dest.directory?)
      assert(dest.empty?)
    end
  end

  test 'copying symlinks' do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(["#{dir}/src", "#{dir}/dest"])
      `touch #{dir}/src/real_file`
      `ln -s #{dir}/src/real_file #{dir}/src/link`
      `ln -s #{Rails.root} #{dir}/src/linked_dir`

      visit files_url(dir)
      find('a', exact_text: 'src').ancestor('tr').find('input[type="checkbox"]').click
      find('#copy-move-btn').click

      visit files_url("#{dir}/dest")
      # one row: No data available in table
      assert_selector '#directory-contents tbody tr', count: 1
      find('#clipboard-copy-to-dir').click

      # src directory is copied
      find('tbody a', exact_text: 'src', wait: MAX_WAIT)

      # and has real file and the symlinks
      visit files_url("#{dir}/dest/src")
      assert_selector '#directory-contents tbody tr', count: 3
      find('tbody a', exact_text: 'real_file', wait: MAX_WAIT)
      find('tbody a', exact_text: 'link', wait: MAX_WAIT)
      find('tbody a[data-type="d"]', exact_text: 'linked_dir', wait: MAX_WAIT)

      # the symlinks are copied as a symlinks and they still point to the same realpath
      sym_file = Pathname.new("#{dir}/dest/src/link")
      sym_dir = Pathname.new("#{dir}/dest/src/linked_dir")
      assert(sym_file.symlink?)
      assert(sym_dir.symlink?)
      assert_equal("#{dir}/src/real_file", sym_file.realpath.to_s)
      assert_equal(Rails.root.to_s, sym_dir.realpath.to_s)
      assert(Pathname.new("#{dir}/dest/src/real_file").file?)
    end
  end

  # similar to the test above, but the symlink is outside of the
  # allowlist. it gets copied, but does not show in the ui.
  test 'copying symlinked files outside of allowlist' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: dir }) do
        FileUtils.mkdir_p(["#{dir}/src", "#{dir}/dest"])
        `touch #{dir}/src/real_file`
        `ln -s /etc/passwd #{dir}/src/link`
        `cd #{dir}/src; ln -s /var/log linked_dir`

        visit files_url(dir)
        find('a', exact_text: 'src').ancestor('tr').find('input[type="checkbox"]').click
        find('#copy-move-btn').click

        visit files_url("#{dir}/dest")
        # one row: No data available in table
        assert_selector '#directory-contents tbody tr', count: 1
        find('#clipboard-copy-to-dir').click

        # src directory is copied
        find('tbody a', exact_text: 'src', wait: MAX_WAIT)

        # but it only shows the real file (no symlinks)
        visit files_url("#{dir}/dest/src")
        assert_selector '#directory-contents tbody tr', count: 1
        find('tbody a', exact_text: 'real_file', wait: MAX_WAIT)

        # the symlink is copied as a symlink as points to the the file outside the allowlist
        sym = Pathname.new("#{dir}/dest/src/link")
        assert(sym.symlink?)
        assert_equal('/etc/passwd', sym.realpath.to_s)
        assert(Pathname.new("#{dir}/dest/src/real_file").file?)

        sym = Pathname.new("#{dir}/dest/src/linked_dir")
        assert(sym.symlink?)
        assert_equal('/var/log', sym.realpath.to_s)
      end
    end
  end

  test 'copying  relative symlinks' do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(["#{dir}/src", "#{dir}/dest"])
      `mkdir -p #{dir}/src/real_dir`
      `touch #{dir}/src/real_file`
      `cd #{dir}/src; ln -s real_file link`
      `cd #{dir}/src; ln -s real_dir linked_dir`

      visit files_url(dir)
      find('a', exact_text: 'src').ancestor('tr').find('input[type="checkbox"]').click
      find('#copy-move-btn').click

      visit files_url("#{dir}/dest")
      # one row: No data available in table
      assert_selector('#directory-contents tbody tr', count: 1)
      find('#clipboard-copy-to-dir').click

      # src directory is copied
      find('tbody a', exact_text: 'src', wait: MAX_WAIT)
      visit files_url("#{dir}/dest/src")

      # assert_selector('#directory-contents tbody tr', count: 4)
      find('tbody a', exact_text: 'real_dir', wait: MAX_WAIT)
      find('tbody a', exact_text: 'real_file', wait: MAX_WAIT)
      find('tbody a', exact_text: 'link', wait: MAX_WAIT)
      find('tbody a', exact_text: 'linked_dir', wait: MAX_WAIT)

      sym_file = Pathname.new("#{dir}/dest/src/link")
      sym_dir = Pathname.new("#{dir}/dest/src/linked_dir")
      assert(sym_file.symlink?)
      assert(sym_dir.symlink?)
      assert_equal('real_file', sym_file.readlink.to_s)
      assert_equal('real_dir', sym_dir.readlink.to_s)
    end
  end

  test 'rename file' do
    Dir.mktmpdir do |dir|
      FileUtils.touch File.join(dir, 'foo.txt')

      visit files_url(dir)
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

  test 'moving files' do
    Dir.mktmpdir do |dir|
      # copy to dest/app
      src = File.join(dir, 'app')
      dest = File.join(dir, 'dest')
      FileUtils.mkpath dest

      `cp -r #{Rails.root.join('app')} #{src}`

      # select dir to move
      visit files_url(dir)
      find('tbody a', exact_text: 'app').ancestor('tr').click
      find('#copy-move-btn').click

      # move to new location
      visit files_url(dest)
      find('#clipboard-move-to-dir').click
      find('tbody a', exact_text: 'app', wait: MAX_WAIT)

      # verify contents moved
      assert_equal '', `diff -rq #{File.join(dest, 'app')} #{Rails.root.join('app')}`.strip,
                   'failed to mv app and all contents'

      # verify original does not exist
      refute File.directory?(src)
    end
  end

  test 'removing files' do
    Dir.mktmpdir do |dir|
      # copy to dest/app
      src = File.join(dir, 'app')
      single_file = File.join(dir, 'single_file')
      `cp -r #{Rails.root.join('app')} #{src}`
      `touch #{single_file}`

      assert File.directory?(src)
      assert File.file?(single_file)

      # select dir to move
      visit files_url(dir)
      find('tbody a', exact_text: 'app').ancestor('tr').check
      find('tbody a', exact_text: 'single_file').ancestor('tr').check
      find('#delete-btn').click
      find('#files_input_modal_ok_button').click

      # verify app dir deleted according to UI
      assert_no_selector 'tbody a', exact_text: 'app', wait: 10
      assert_no_selector 'tbody a', exact_text: 'single_file', wait: 10

      # verify app dir & single_file were actually deleted
      refute(File.exist?(src), Dir.children(dir))
      refute(File.exist?(single_file), Dir.children(dir))
    end
  end

  test 'uploading files' do
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
      File.stubs(:umask).returns(18) # ensure default umask is 644
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
      assert_equal(33_188, File.stat(upload_file).mode) # default 644

      # now change the permissions and verify
      `chmod 755 #{upload_file}`
      assert_equal(33_261, File.stat(upload_file).mode) # now 755

      # add something more to the original file
      `echo 'and some more content' >> #{src_file}`

      # upload the file again
      find('#upload-btn').click
      find('.uppy-Dashboard-AddFiles', wait: MAX_WAIT)
      attach_file 'files[]', src_file, visible: false, match: :first
      find('.uppy-StatusBar-actionBtn--upload', wait: MAX_WAIT).click
      find('tbody a', exact_text: File.basename(src_file), wait: MAX_WAIT)

      # and it's still there, now with new content and it keeps the 755 permissions
      assert File.exist?(upload_file)
      assert_equal File.read(src_file), File.read(upload_file)
      assert_equal File.stat(upload_file).mode, 33_261 # still 755
    end
  end

  test 'changing directory' do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app')
    find('tbody a', exact_text: 'config')

    find('#goto-btn').click
    find('#files_input_modal_input').set(Rails.root.join('app'))
    find('#files_input_modal_ok_button').click
    find('tbody a', exact_text: 'helpers')
    find('tbody a', exact_text: 'controllers')

    find('#goto-btn').click
    find('#files_input_modal_input').set(Rails.root.to_s)
    find('#files_input_modal_ok_button').click
    find('tbody a', exact_text: 'app')
    find('tbody a', exact_text: 'config')
  end

  test 'edit file' do
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
        find('textarea.ace_text-input', visible: false).send_keys('foobar')

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

  test 'symlinked files outside of allowlist' do
    Dir.mktmpdir do |dir|
      allowed_dir = "#{dir}/allowed"
      with_modified_env({ OOD_ALLOWLIST_PATH: allowed_dir }) do
        `mkdir -p #{allowed_dir}`
        `mkdir -p #{allowed_dir}/some_dir`
        `touch #{allowed_dir}/some_file`

        `mkdir -p #{dir}/not_allowed`
        `ln -s #{dir}/not_allowed #{allowed_dir}/symlinked_dir`

        visit files_url(allowed_dir)

        # 3 things are actually in the directory
        assert_equal(3, Dir.children(allowed_dir).size)

        # but only 2 things are shown in the UI (symlinked_dir is missing)
        find('tbody a', exact_text: 'some_dir')
        find('tbody a', exact_text: 'some_file')
        assert_selector('tbody span[title="directory"]', count: 1)
        assert_selector('tbody span[title="file"]', count: 1)
      end
    end
  end

  test 'can download hidden files and directories' do
    zip_file = DOWNLOAD_DIRECTORY.join('test_dir.zip')
    File.delete(zip_file) if File.exist?(zip_file)

    Dir.mktmpdir do |dir|
      dir_to_dl = "#{dir}/test_dir"
      `mkdir -p #{dir_to_dl}/first_level_dir`
      `mkdir #{dir_to_dl}/.first_level_hidden_dir`
      `echo 'abc123' > #{dir_to_dl}/real_file`
      `echo 'abc123' > #{dir_to_dl}/first_level_dir/.second_level_hidden_file`
      `echo 'abc123' > #{dir_to_dl}/first_level_dir/second_level_real_file`
      `echo 'abc123' > #{dir_to_dl}/.first_level_hidden_dir/.another_second_level_hidden_file`
      `echo 'abc123' > #{dir_to_dl}/.first_level_hidden_dir/another_second_level_real_file`

      visit files_url(dir)
      find('tbody a', exact_text: 'test_dir').ancestor('tr').click
      click_on('Download')

      sleep 5 # give it enough time to download
      assert(File.exist?(zip_file), "#{zip_file} was never downloaded!")

      # unzip all the files you downloaded into a new tmp directory and iterate
      # though them. Verify that the file you downloaded exists in the original tmpdir 'dir'.
      Dir.mktmpdir do |unzip_tmp_dir|
        `cd #{unzip_tmp_dir}; unzip #{zip_file}`
        Dir.glob("#{dir_to_dl}/**/*", File::FNM_DOTMATCH).reject do |file_to_dl|
          ['.', '..'].freeze.include?(File.basename(file_to_dl))

          # get the relative path
        end.map do |path_to_dl|
          path_to_dl.gsub(dir_to_dl, '').delete_prefix('/')

          # now combine the relative path with the new unzipped directory and verify that
          # the file exists in the unzipped directory
        end.each do |relative_path_to_dl|
          assert(File.exist?("#{unzip_tmp_dir}/#{relative_path_to_dl}"), "#{relative_path_to_dl} was not downloaded!")
        end
      end

      File.delete(zip_file) if File.exist?(zip_file)
    end
  end

  test 'cannot download files outside of allowlist' do
    zip_file = DOWNLOAD_DIRECTORY.join('allowed.zip')
    File.delete(zip_file) if File.exist?(zip_file)

    Dir.mktmpdir do |dir|
      allowed_dir = "#{dir}/allowed"
      with_modified_env({ OOD_ALLOWLIST_PATH: dir }) do
        `mkdir -p #{allowed_dir}/real_directory`
        `touch #{allowed_dir}/real_file`
        `touch #{allowed_dir}/real_directory/other_real_file`
        `ln -s #{Rails.root.join('README.md')} #{allowed_dir}/sym_linked_file`
        `ln -s #{Rails.root} #{allowed_dir}/sym_linked_directory`

        visit files_url(dir)
        find('tbody a', exact_text: 'allowed').ancestor('tr').click
        click_on('Download')

        sleep 5 # give it enough time to download
        assert(File.exist?(zip_file), "#{zip_file} was never downloaded!")

        Dir.mktmpdir do |unzip_tmp_dir|
          `cd #{unzip_tmp_dir}; unzip #{zip_file}`
          assert(File.exist?("#{unzip_tmp_dir}/real_directory"))
          assert(File.directory?("#{unzip_tmp_dir}/real_directory"))
          assert(File.exist?("#{unzip_tmp_dir}/real_directory/other_real_file"))
          assert(File.exist?("#{unzip_tmp_dir}/real_file"))

          refute(File.exist?("#{unzip_tmp_dir}/sym_linked_file"))
          refute(File.exist?("#{unzip_tmp_dir}/sym_linked_directory"))
        end
      end
    end

    File.delete(zip_file) if File.exist?(zip_file)
  end

  test 'favorite paths outside allowlist do not show up' do
    Dir.mktmpdir do |dir|
      allowed_dir = "#{dir}/allowed_dir"
      not_allowed_dir = "#{dir}/not_allowed_dir"
      with_modified_env({ OOD_ALLOWLIST_PATH: allowed_dir }) do
        `mkdir -p #{allowed_dir}`
        `touch #{allowed_dir}/test_file.txt`
        `mkdir -p #{not_allowed_dir}`
        `touch #{not_allowed_dir}/test_file.txt`
        favorites = [FavoritePath.new(allowed_dir), FavoritePath.new(not_allowed_dir)]
        OodFilesApp.stubs(:candidate_favorite_paths).returns(favorites)

        visit files_url(dir)
        assert_selector('#favorites li', count: 2)
      end
    end
  end

  test 'handles files with non utf-8 characters' do
    Dir.mktmpdir do |dir|
      prefix = [255, 1, 2, 3].pack('C*')
      bad_file = "#{prefix}-test.txt"
      `touch #{dir}/#{bad_file}`
      `touch #{dir}/good_file.txt`

      visit files_url(dir)

      # only 1 file and it's the good one.
      assert_selector('tbody a', count: 1)
      find('tbody a', exact_text: 'good_file.txt')
    end
  end

  test 'unreadable files and fifos are not downloadable' do
    Dir.mktmpdir do |dir|
      cant_read = 'cant_read.txt'
      fifo = 'fifo'

      `touch #{dir}/#{cant_read}`
      `chmod 000 #{dir}/#{cant_read}`
      `mkfifo #{dir}/#{fifo}`

      visit files_url(dir)

      fifo_row = find('tbody a', exact_text: fifo).ancestor('tr')
      cant_read_row = find('tbody a', exact_text: cant_read).ancestor('tr')

      fifo_row.find('button.dropdown-toggle').click
      fifo_links = fifo_row.all('td > div.btn-group > ul > li > a').map(&:text)

      cant_read_row.find('button.dropdown-toggle').click
      cant_read_links = cant_read_row.all('td > div.btn-group > ul > li > a').map(&:text)

      # NOTE: download and view are not an expected links.
      expected_links = ['Edit', 'Rename', 'Delete']

      assert_equal(expected_links, fifo_links)
      assert_equal(expected_links, cant_read_links)
    end
  end

  test 'block devices are not downloadable' do
    visit files_url('/dev')

    null_row = find('tbody a', exact_text: 'null').ancestor('tr')
    null_row.find('button.dropdown-toggle').click
    null_links = null_row.all('td > div.btn-group > ul > li > a').map(&:text)

    # NOTE: download and view are not an expected links.
    expected_links = ['Edit', 'Rename', 'Delete']

    assert_equal(expected_links, null_links)
  end

  test 'download button is disabled when non-downloadable item is checked' do
    Dir.mktmpdir do |dir|
      cant_read = 'cant_read.txt'
      can_read = 'can_read.txt'

      `touch #{dir}/#{can_read}`
      `touch #{dir}/#{cant_read}`
      `chmod 000 #{dir}/#{cant_read}`

      visit files_url(dir)

      can_read_row = find('tbody a', exact_text: can_read).ancestor('tr')
      cant_read_row = find('tbody a', exact_text: cant_read).ancestor('tr')

      can_read_row.find('input[type="checkbox"]').check

      refute find('#download-btn').disabled?

      cant_read_row.find('input[type="checkbox"]').check

      assert find('#download-btn').disabled?
    end
  end

  test 'download button is re-enabled when non-downloadable item is unchecked' do
    Dir.mktmpdir do |dir|
      cant_read = 'cant_read.txt'

      `touch #{dir}/#{cant_read}`
      `chmod 000 #{dir}/#{cant_read}`

      visit files_url(dir)

      cant_read_row = find('tbody a', exact_text: cant_read).ancestor('tr')
      cant_read_row.find('input[type="checkbox"]').check
      assert find('#download-btn').disabled?

      cant_read_row.find('input[type="checkbox"]').uncheck
      refute find('#download-btn').disabled?
    end
  end

  test 'download button is NOT re-enabled until ALL non-downloadable files are unchecked' do
    Dir.mktmpdir do |dir|
      cant_read1 = 'cant_read1.txt'
      cant_read2 = 'cant_read2.txt'

      `touch #{dir}/#{cant_read1}`
      `touch #{dir}/#{cant_read2}`
      `chmod 000 #{dir}/#{cant_read1}`
      `chmod 000 #{dir}/#{cant_read2}`

      visit files_url(dir)

      cant_read1_row = find('tbody a', exact_text: cant_read1).ancestor('tr')
      cant_read2_row = find('tbody a', exact_text: cant_read2).ancestor('tr')

      cant_read1_row.find('input[type="checkbox"]').check
      assert find('#download-btn').disabled?

      cant_read2_row.find('input[type="checkbox"]').check
      assert find('#download-btn').disabled?

      cant_read1_row.find('input[type="checkbox"]').uncheck
      assert find('#download-btn').disabled?

      cant_read2_row.find('input[type="checkbox"]').uncheck
      refute find('#download-btn').disabled?
    end
  end

  test 'allowlist errors flash' do
    with_modified_env({ OOD_ALLOWLIST_PATH: Rails.root.to_s }) do
      visit(files_url(Rails.root))

      alerts = all('.alert')
      assert(alerts.empty?)

      find('#goto-btn').click
      find('#files_input_modal_input').set('/etc')
      find('#files_input_modal_ok_button').click

      alerts = all('.alert')
      refute(alerts.empty?)
      assert_equal(1, alerts.size)

      alert_text = find('.alert > span').text
      assert_equal('/etc does not have an ancestor directory specified in ALLOWLIST_PATH', alert_text)
    end
  end

  test 'files have hrefs when download is enabled' do
    visit(files_url(Rails.root))
    find('#show-dotfiles').click
    files = Dir.children(Rails.root).reject { |f| Pathname.new(f).directory? }

    file_elements = find_all('[data-type="f"]')

    # all files are shown in the table.
    assert_equal(files.size, file_elements.size)

    # all the HTML elements have hrefs.
    assert(file_elements.all? { |e| !e[:href].nil? })
  end

  test 'files do not have hrefs when download is enabled' do
    with_modified_env({ OOD_DOWNLOAD_ENABLED: 'false' }) do
      visit(files_url(Rails.root))
      find('#show-dotfiles').click
      files = Dir.children(Rails.root).reject { |f| Pathname.new(f).directory? }

      file_elements = find_all('[data-type="f"]')

      # all files are shown in the table.
      assert_equal(files.size, file_elements.size)

      # none of the HTML elements have hrefs.
      assert(file_elements.all? { |e| e[:href].nil? })
    end
  end

  test 'filenames are correctly escaped' do
    bad_fname = '<img src=1 onerror=alert(\"hello\")>'
    `touch "tmp/#{bad_fname}"`
    visit(files_url("#{Rails.root}/tmp"))

    # innerHTML returns escaped text, i.e., '&lt;' not '<'.
    actual_text = find('tbody a', text: 'onerror')[:innerHTML]

    assert_equal('&lt;img src=1 onerror=alert("hello")&gt;', actual_text)
  end
end
