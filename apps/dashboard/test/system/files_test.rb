require "application_system_test_case"

class FilesTest < ApplicationSystemTestCase
  test "visiting files app doesn't raise js errors" do
    visit files_url(Rails.root.to_s)

    messages = page.driver.browser.manage.logs.get(:browser)
    content = messages.join("\n")
    assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"

    # problem with using capybara and the Rails system tests:
    # https://github.com/rails/rails/issues/39987
    # though supposedly it still works with headless chrome https://github.com/rails/rails/pull/37792
    # but watching it visually makes it easier to debug
  end

  test "visiting files app directory" do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app').ancestor('tr').click
    assert_selector '.selected', count: 1
    find('tbody a', exact_text: 'config').ancestor('tr').click(:meta)
    assert_selector '.selected', count: 2
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

      # if this fails it is due to the directory table not reloading
      assert_selector '#directory-contents tbody tr', count: 3, wait: 10

      #TODO: this is a common need so lets make this easy to do
      # assert diff on individual files

      assert_equal "", `diff -rq #{File.join(dir, 'app')} #{Rails.root.join('app').to_s}`.strip, "failed to recursively copy app dir"
      assert_equal "", `diff -rq #{File.join(dir, 'config')} #{Rails.root.join('config').to_s}`.strip, "failed to recursively copy config dir"
      assert_equal "", `diff -q #{File.join(dir, 'manifest.yml')} #{Rails.root.join('manifest.yml').to_s}`.strip, "failed to copy manifest.yml"
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


      assert_selector 'tbody a', exact_text: 'bar.txt', wait: 10
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
      assert_selector 'tbody a', exact_text: 'app', wait: 10

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

  test "adding new file" do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-file-btn').click
      find('#swal2-input').set('bar.txt')
      find('.swal2-confirm').click
      assert_selector 'tbody a', exact_text: 'bar.txt', wait: 10
      assert File.file? File.join(dir, 'bar.txt')
    end
  end

  test "adding a new directory" do
    Dir.mktmpdir do |dir|
      visit files_url(dir)
      find('#new-dir-btn').click
      find('#swal2-input').set('bar')
      find('.swal2-confirm').click
      assert_selector 'tbody a.d', exact_text: 'bar', wait: 10
      assert File.directory? File.join(dir, 'bar')
    end
  end
end
