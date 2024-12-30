require 'test_helper'

class FilesTest < ActiveSupport::TestCase
  test "mime_type raises exception for non-file" do
    assert_raises { PosixFile.new("/dev/nulll").mime_type }
  end

  test "mime_type handles default types" do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.txt')
      File.write(f, "one two three")

      assert_equal "text/plain", PosixFile.new(f).mime_type
    end
  end

  test "mime_type handles png" do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.svg')
      FileUtils.cp(Rails.root.join('app/assets/images/OpenOnDemand_powered_by_RGB.svg').to_s, f)

      assert_equal "image/svg+xml", PosixFile.new(f).mime_type
    end
  end

  test "mime_type handles empty file" do
    # "inode/x-empty" is returned by file command on empty file
    # we want to treat this as an empty file of "text/plain"
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'foo.txt')
      FileUtils.touch f

      assert_equal "text/plain", PosixFile.new(f).mime_type, 'should treat "inode/x-empty" as "text/plain"'
    end
  end

  test "can_download_as_zip handles erroneous output from du" do
    Dir.mktmpdir do |dir|
      error_msg = 'some failure message'
      Open3.stubs(:capture3).returns(["blarg \n 28d", error_msg, exit_failure])
      result = PosixFile.new(dir).can_download_as_zip?
      error = I18n.t('dashboard.files_directory_size_unknown', exit_code: '1', error: error_msg)

      assert_equal [false, error], result
    end 
  end

  test "can_download_as_zip handles unauthorized directory" do
    Dir.mktmpdir do |dir|
      FileUtils.chmod(0400, dir)  # Read-only permission
      result = PosixFile.new(dir).can_download_as_zip?
      error = I18n.t('dashboard.files_directory_download_unauthorized')
  
      assert_equal [false, error], result
    end
  end

  test "can_download_as_zip handles directory size calculation timeout" do
    Dir.mktmpdir do |dir|
      Open3.stubs(:capture3).returns(["", "Timeout", exit_failure(124)])
      result = PosixFile.new(dir).can_download_as_zip?
      error = I18n.t('dashboard.files_directory_size_calculation_timeout')

      assert_equal [false, error], result
    end
  end

  test "can_download_as_zip handles directory size calculation error" do
    Dir.mktmpdir do |dir|
      Open3.stubs(:capture3).returns(["", "", exit_success])
      result = PosixFile.new(dir).can_download_as_zip?
      error = I18n.t('dashboard.files_directory_size_calculation_error')

      assert_equal [false, error], result
    end
  end

  test "can_download_as_zip handles files sizes of 0" do
    Dir.mktmpdir do |dir|
      Open3.stubs(:capture3).returns(["0 /dev
        0 total", "", exit_success])

      assert_equal [true, nil], PosixFile.new(dir).can_download_as_zip?
    end 
  end

  test "can_download_as_zip handles directory size exceeding limit" do
    download_directory_size_limit = Configuration.file_download_dir_max
    Dir.mktmpdir do |dir|
      dir_size = download_directory_size_limit + 1
      PosixFile.any_instance.stubs(:calculate_directory_size)
        .returns(download_directory_size_limit + 1)
      Open3.stubs(:capture3).returns(["#{dir_size} #{dir} 
        \n #{dir_size} total", "", exit_success])
      result = PosixFile.new(dir).can_download_as_zip?
      error = I18n.t('dashboard.files_directory_too_large', download_directory_size_limit: download_directory_size_limit)

      assert_equal([false, error], result)
    end 
  end

  test "Ensuring PosixFile.username(uid) returns string" do
    assert_equal "9999999", PosixFile.username(9999999)
  end

  test 'files not in allowlist are invalid' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: "#{dir}/allowed" }) do
        `mkdir -p #{dir}/allowed`
        `mkdir -p #{dir}/not_allowed`
        invalid_file = "#{dir}/not_allowed/actual_file"
        `touch #{invalid_file}`

        file = PosixFile.new(invalid_file)
        refute(file.valid?)
      end
    end
  end

  test 'symlinks outside allowlist are invalid' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: "#{dir}/allowed" }) do
        `mkdir -p #{dir}/allowed`
        `mkdir -p #{dir}/not_allowed`
        real_file = "#{dir}/not_allowed/actual_file"
        symlink = "#{dir}/allowed/linked_file"
        `touch #{real_file}`
        `ln -s #{real_file} #{symlink}`

        real_file = PosixFile.new(real_file)
        symlink = PosixFile.new(symlink)

        # both are invalid because they're not in the allowlist
        refute(symlink.valid?)
        refute(real_file.valid?)
      end
    end
  end

  test 'ls output does not show invalid files' do
    Dir.mktmpdir do |dir|
      with_modified_env({ OOD_ALLOWLIST_PATH: "#{dir}/allowed" }) do
        `mkdir -p #{dir}/allowed`
        `mkdir -p #{dir}/not_allowed`
        real_file = "#{dir}/not_allowed/actual_file"
        symlink = "#{dir}/allowed/linked_file"
        `touch #{real_file}`

        # symlink resolves outside of allowlist
        `ln -s #{real_file} #{symlink}`

        # this file would be allowed - but is a broken symlink
        `touch #{dir}/allowed/tmp`
        `ln -s #{dir}/allowed/tmp #{dir}/allowed/broken_symlink`
        `rm #{dir}/allowed/tmp`

        # they exist, but cannot be seen
        assert_equal(1, PosixFile.new(dir).ls.size)
        assert_equal(2, Dir.children(dir).size)

        assert_equal(0, PosixFile.new("#{dir}/allowed").ls.size)
        assert_equal(2, Dir.children("#{dir}/allowed").size)
      end
    end
  end

  test 'unreadable files are not downloadable' do
    Dir.mktmpdir do |dir|
      file = File.join(dir, 'foo.text')
      FileUtils.touch(file)
      # make sure file is not readable, a condition of PosixFile#downloadable?
      FileUtils.chmod(0o0333, file)

      refute(PosixFile.new(file).downloadable?)
    end
  end

  test 'fifo pipes are not downloadable' do
    Dir.mktmpdir do |dir|
      file = "#{dir}/test.fifo"
      `mkfifo #{file}`

      refute(PosixFile.new(file).downloadable?)
    end
  end

  test 'block devices are not downloadable' do
    block_dev = Dir.children('/dev').map do |p|
                  Pathname.new("/dev/#{p}")
                end.select(&:blockdev?).first

    assert(block_dev.exist?)
    assert(block_dev.blockdev?)
    refute(PosixFile.new(block_dev.to_s).downloadable?)
  end

  test 'character devices are not downloadable' do
    char_dev = Dir.children('/dev').map do |p|
                 Pathname.new("/dev/#{p}")
               end.select(&:chardev?).first

    assert(char_dev.exist?)
    assert(char_dev.chardev?)
    refute(PosixFile.new(char_dev.to_s).downloadable?)
  end
end
