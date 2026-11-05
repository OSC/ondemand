# frozen_string_literal: true

require 'test_helper'

class ClusterFileTest < ActiveSupport::TestCase
  def setup
    @adapter = stub('file_adapter')
    @cluster = OodCore::Cluster.new({ id: 'remote', job: { adapter: 'slurm' } })
    @cluster.stubs(:file_adapter).returns(@adapter)

    OODClusters.stubs(:[]).returns(nil)
    OODClusters.stubs(:[]).with(any_of(:remote, 'remote')).returns(@cluster)
  end

  def cluster_file(path = '/home/me/dir')
    ClusterFile.new(path, 'remote')
  end

  test 'raises for an unknown cluster' do
    e = assert_raises(StandardError) { ClusterFile.new('/home/me', 'unknown') }
    assert_equal 'No such cluster for ClusterFile: unknown', e.message
  end

  test 'uses the file adapter of the cluster' do
    file = cluster_file

    assert_equal @cluster, file.cluster
    assert_equal @adapter, file.file_adapter
    assert_equal 'cluster', file.remote_type
  end

  test 'ls adds the fields the adapter does not return' do
    @adapter.stubs(:ls).with(Pathname.new('/home/me/dir')).returns([
      { name: 'a.txt', size: 3, directory: false, date: 1_700_000_000, owner: 'me', mode: 0o100644 }
    ])

    expected = [{
      id: '/home/me/dir/a.txt', dev: 0, downloadable: true,
      name: 'a.txt', size: 3, directory: false, date: 1_700_000_000, owner: 'me', mode: 0o100644
    }]
    assert_equal expected, cluster_file.ls
  end

  test 'ls lists directories first' do
    @adapter.stubs(:ls).returns([
      { name: 'a.txt', directory: false },
      { name: 'sub', directory: true },
      { name: 'b.txt', directory: false }
    ])

    files = cluster_file.ls
    assert_equal [true, false, false], files.map { |f| f[:directory] }
    assert_equal 'sub', files.first[:name]
  end

  test 'ls leaves out files whose names are not UTF-8' do
    @adapter.stubs(:ls).returns([
      { name: 'good.txt', directory: false },
      { name: "bad\xFF.txt", directory: false }
    ])

    assert_equal ['good.txt'], cluster_file.ls.map { |f| f[:name] }
  end

  test 'mime_type treats empty files as text' do
    @adapter.stubs(:mime_type).returns('inode/x-empty')

    assert_equal 'text/plain', cluster_file('/home/me/empty').mime_type
  end

  test 'mime_type returns the type from the adapter' do
    @adapter.stubs(:mime_type).with(Pathname.new('/home/me/image.png')).returns('image/png')

    assert_equal 'image/png', cluster_file('/home/me/image.png').mime_type
  end

  test 'can_download_file? when the file is small enough and readable' do
    Configuration.stubs(:download_file_max).returns(100)
    @adapter.stubs(:size).returns(100)
    @adapter.stubs(:readable?).returns(true)

    assert_equal [true, nil], cluster_file('/home/me/a.txt').can_download_file?
  end

  test 'can_download_file? when the file is too large' do
    Configuration.stubs(:download_file_max).returns(100)
    @adapter.stubs(:size).returns(101)
    @adapter.expects(:readable?).never

    expected = [false, I18n.t('dashboard.files_file_too_large', download_file_size_limit: 100)]
    assert_equal expected, cluster_file('/home/me/a.txt').can_download_file?
  end

  test 'can_download_file? when the file is not readable' do
    Configuration.stubs(:download_file_max).returns(100)
    @adapter.stubs(:size).returns(1)
    @adapter.stubs(:readable?).with(Pathname.new('/home/me/a.txt')).returns(false)

    expected = [false, I18n.t('dashboard.files_not_readable', path: '/home/me/a.txt')]
    assert_equal expected, cluster_file('/home/me/a.txt').can_download_file?
  end

  test 'can_download_as_zip? when the directory is small enough' do
    @adapter.expects(:directory_size).with(Pathname.new('/home/me/dir'), timeout: 5).returns(100)

    assert_equal [true, nil], cluster_file.can_download_as_zip?(timeout: 5, download_directory_size_limit: 100)
  end

  test 'can_download_as_zip? when the directory is too large' do
    @adapter.stubs(:directory_size).returns(101)

    expected = [false, I18n.t('dashboard.files_directory_too_large', download_directory_size_limit: 100)]
    assert_equal expected, cluster_file.can_download_as_zip?(timeout: 5, download_directory_size_limit: 100)
  end

  test 'can_download_as_zip? when calculating the size times out' do
    @adapter.stubs(:directory_size).raises(Timeout::Error)

    expected = [false, I18n.t('dashboard.files_directory_size_calculation_timeout')]
    assert_equal expected, cluster_file.can_download_as_zip?(timeout: 5, download_directory_size_limit: 100)
  end

  test 'can_download_as_zip? when calculating the size fails' do
    @adapter.stubs(:directory_size).raises(StandardError, 'du failed')

    expected = [false, I18n.t('dashboard.files_directory_size_error', error: 'du failed')]
    assert_equal expected, cluster_file.can_download_as_zip?(timeout: 5, download_directory_size_limit: 100)
  end

  test 'files_to_zip uses paths relative to the directory and leaves out the directory itself' do
    @adapter.stubs(:ls_recursive).with(Pathname.new('/home/me/dir')).returns([
      '/home/me/dir', '/home/me/dir/a.txt', '/home/me/dir/sub', '/home/me/dir/sub/b.txt'
    ])

    files = cluster_file.files_to_zip
    assert_equal ['a.txt', 'sub', 'sub/b.txt'], files.map(&:relative_path)
    assert_equal ['/home/me/dir/a.txt', '/home/me/dir/sub', '/home/me/dir/sub/b.txt'], files.map(&:path)
  end

  test 'files_to_zip leaves out files whose names are not UTF-8' do
    @adapter.stubs(:ls_recursive).returns(['/home/me/dir', '/home/me/dir/a.txt', "/home/me/dir/bad\xFF.txt"])

    assert_equal ['a.txt'], cluster_file.files_to_zip.map(&:relative_path)
  end

  test 'download_as_zip skips files that fail to be read' do
    @adapter.stubs(:ls_recursive).returns(['/home/me/dir', '/home/me/dir/a.txt', '/home/me/dir/b.txt',
                                           '/home/me/dir/c.txt'])
    @adapter.stubs(:read).with('/home/me/dir/a.txt').multiple_yields(['aaa'], ['AAA'])
    @adapter.stubs(:read).with('/home/me/dir/b.txt').raises(StandardError, 'Permission denied')
    @adapter.stubs(:read).with('/home/me/dir/c.txt').yields('ccc')

    zip = StringIO.new
    cluster_file.download_as_zip(zip)
    zip.rewind

    entries = ZipKit::FileReader.read_zip_structure(io: zip)
    assert_equal ['a.txt', 'c.txt'], entries.map(&:filename)

    contents = entries.map do |entry|
      entry.extractor_from(zip).extract
    end
    assert_equal ['aaaAAA', 'ccc'], contents
  end

  test 'touch creates the file on the cluster' do
    @adapter.expects(:touch).with(Pathname.new('/home/me/dir/new.txt'))

    cluster_file('/home/me/dir/new.txt').touch
  end

  test 'mkdir creates the directory on the cluster' do
    @adapter.expects(:mkdir).with(Pathname.new('/home/me/dir/new'))

    cluster_file('/home/me/dir/new').mkdir
  end

  test 'write writes the content to the file on the cluster' do
    @adapter.expects(:write).with(Pathname.new('/home/me/dir/a.txt'), 'content')

    cluster_file('/home/me/dir/a.txt').write('content')
  end

  test 'handle_upload moves the tempfile to the cluster' do
    tempfile = Tempfile.new('upload')
    ClusterTransfer.any_instance.expects(:perform_later)

    transfer = cluster_file('/home/me/dir/upload.txt').handle_upload(tempfile)

    assert_equal 'mv', transfer.action
    assert_equal({ tempfile.path => '/home/me/dir/upload.txt' }, transfer.files)
    assert_equal 'fs', transfer.src_fs
    assert_equal @cluster, transfer.dest_fs
    assert_equal @adapter, transfer.adapter
    assert_equal tempfile, transfer.tempfile
  ensure
    tempfile&.close(true)
  end
end
