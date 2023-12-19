require "application_system_test_case"

class FilesTest < ApplicationSystemTestCase

  MAX_WAIT = 120

  def setup
    FileUtils.rm_rf(DOWNLOAD_DIRECTORY.to_s)
    FileUtils.mkdir_p(DOWNLOAD_DIRECTORY.to_s)
  end

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
      find('button.swal2-confirm').click

      # verify app dir deleted according to UI
      assert_no_selector 'tbody a', exact_text: 'app', wait: 10
      assert_no_selector 'tbody a', exact_text: 'single_file', wait: 10

      # verify app dir & single_file were actually deleted
      refute(File.exist?(src), Dir.children(dir))
      refute(File.exist?(single_file), Dir.children(dir))
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
      `touch #{dir_to_dl}/real_file`
      `touch #{dir_to_dl}/first_level_dir/.second_level_hidden_file`
      `touch #{dir_to_dl}/first_level_dir/second_level_real_file`
      `touch #{dir_to_dl}/.first_level_hidden_dir/.another_second_level_hidden_file`
      `touch #{dir_to_dl}/.first_level_hidden_dir/another_second_level_real_file`

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
end
