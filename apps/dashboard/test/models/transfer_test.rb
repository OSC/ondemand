require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  test 'copy command' do
    transfer = PosixTransfer.build action: 'cp', files: {
      '/Users/efranz/dev/ondemand/apps/dashboard/app' => '/var/folders/w7/fn8w83s10510pkc5j2wq8cpnhxtn3j/T/d20210201-68201-u3azoj/app',
      '/Users/efranz/dev/ondemand/apps/dashboard/config' => '/var/folders/w7/fn8w83s10510pkc5j2wq8cpnhxtn3j/T/d20210201-68201-u3azoj/config',
      '/Users/efranz/dev/ondemand/apps/dashboard/manifest.yml' => '/var/folders/w7/fn8w83s10510pkc5j2wq8cpnhxtn3j/T/d20210201-68201-u3azoj/manifest.yml'
    }

    expected = []
    assert_equal expected, transfer.commands
  end

  test 'percent progress' do
    transfer = Transfer.new
    transfer.stubs(:steps).returns(100)

    assert_equal 0, transfer.percent
    transfer.update_percent 1
    assert_equal 1, transfer.percent
    transfer.update_percent 50
    assert_equal 50, transfer.percent
    transfer.update_percent 100
    assert_equal 100, transfer.percent
  end

  test '1 step for file copy' do
    assert_equal 1, PosixTransfer.build(action: 'cp', files: { 'config.ru' => '/tmp/config.ru' }).steps
  end

  test '1 step for file removal' do
    assert_equal 1, PosixTransfer.build(action: 'rm', files: ['config.ru']).steps
  end

  test '1 step for file mv' do
    assert_equal 1, PosixTransfer.build(action: 'mv', files: { 'config.ru' => 'config.ru.2' }).steps
  end

  test 'copying a files is 1:1 files:steps' do
    files = Dir['bin/*'].map { |f| File.basename(f) }
    new_files = files.map { |f| "#{f}.2" }
    all_files = files.zip(new_files).to_h

    assert_equal(files.size, PosixTransfer.build(action: 'cp', files: all_files).steps)
  end

  # This tests https://github.com/OSC/ondemand/issues/1337 and fails if it's not patched
  test 'rm works when allowlists are enabled' do
    Dir.mktmpdir do |tmpdir|
      Configuration.stubs(:allowlist_paths).returns([tmpdir])

      f = "#{tmpdir}/myfile"
      FileUtils.touch f
      assert_equal true, File.exist?(f)

      t = PosixTransfer.build(action: 'rm', files: [f])
      assert_equal true, t.valid?, t.errors.full_messages.join('. ')
      assert_equal 1, t.steps

      t.perform
      assert_equal false, File.exist?(f)
    end
  end
end