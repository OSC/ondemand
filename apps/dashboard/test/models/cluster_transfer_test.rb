# frozen_string_literal: true

require 'test_helper'

class ClusterTransferTest < ActiveSupport::TestCase
  def setup
    @adapter = stub('file_adapter')
    @cluster = OodCore::Cluster.new({ id: 'remote', job: { adapter: 'slurm' } })
    @cluster.stubs(:file_adapter).returns(@adapter)

    OODClusters.stubs(:[]).returns(nil)
    OODClusters.stubs(:[]).with(:remote).returns(@cluster)
  end

  test 'build converts a list of files to remove to a hash' do
    transfer = ClusterTransfer.build(action: 'rm', files: ['/home/me/a', '/home/me/b'], src_fs: 'remote',
                                     dest_fs: 'remote')

    assert_equal({ '/home/me/a' => nil, '/home/me/b' => nil }, transfer.files)
  end

  test 'build resolves the cluster and its file adapter for an upload' do
    transfer = ClusterTransfer.build(action: 'cp', files: { '/tmp/a' => '/home/me/a' }, src_fs: 'fs',
                                     dest_fs: 'remote')

    assert_equal 'fs', transfer.src_fs
    assert_equal @cluster, transfer.dest_fs
    assert_equal @adapter, transfer.adapter
  end

  test 'build resolves the cluster and its file adapter for a download' do
    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a' }, src_fs: 'remote',
                                     dest_fs: 'fs')

    assert_equal @cluster, transfer.src_fs
    assert_equal 'fs', transfer.dest_fs
    assert_equal @adapter, transfer.adapter
  end

  test 'upload is valid when nothing in the destination has the same name' do
    @adapter.stubs(:ls).with('/home/me/dir').returns([{ name: 'other' }])

    transfer = ClusterTransfer.build(action: 'cp', files: { '/tmp/a' => '/home/me/dir/a' }, src_fs: 'fs',
                                     dest_fs: 'remote')

    assert transfer.valid?, transfer.errors.full_messages.join('. ')
  end

  test 'upload is invalid when the destination already has files with the same names' do
    @adapter.stubs(:ls).with('/home/me/dir').returns([{ name: 'a' }, { name: 'b' }, { name: 'other' }])

    transfer = ClusterTransfer.build(action: 'mv',
                                     files:  { '/tmp/a' => '/home/me/dir/a', '/tmp/b' => '/home/me/dir/b',
                                               '/tmp/c' => '/home/me/dir/c' },
                                     src_fs: 'fs', dest_fs: 'remote')

    assert_not transfer.valid?
    assert_equal ['These files already exist: /home/me/dir/a, /home/me/dir/b'], transfer.errors.full_messages
  end

  test 'copy within the cluster is invalid when the destination already has files with the same names' do
    @adapter.stubs(:ls).with('/home/me/dir').returns([{ name: 'a' }])

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/home/me/dir/a' }, src_fs: 'remote',
                                     dest_fs: 'remote')

    assert_not transfer.valid?
    assert_equal ['These files already exist: /home/me/dir/a'], transfer.errors.full_messages
  end

  test 'upload is invalid when listing the destination fails' do
    @adapter.stubs(:ls).raises(StandardError, 'No such file or directory')

    transfer = ClusterTransfer.build(action: 'cp', files: { '/tmp/a' => '/home/me/dir/a' }, src_fs: 'fs',
                                     dest_fs: 'remote')

    assert_not transfer.valid?
    assert_equal ['Error checking existing files in destination: No such file or directory'],
                 transfer.errors.full_messages
  end

  test 'download is invalid when local files with the same names exist' do
    Dir.mktmpdir do |dir|
      FileUtils.touch("#{dir}/a")

      transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => "#{dir}/a", '/home/me/b' => "#{dir}/b" },
                                       src_fs: 'remote', dest_fs: 'fs')

      assert_not transfer.valid?
      assert_equal ["These files already exist: #{dir}/a"], transfer.errors.full_messages
    end
  end

  test 'remove does not check for existing files' do
    @adapter.expects(:ls).never

    transfer = ClusterTransfer.build(action: 'rm', files: ['/home/me/a'], src_fs: 'remote', dest_fs: 'remote')

    assert transfer.valid?, transfer.errors.full_messages.join('. ')
  end

  test 'remove is valid with an allowlist' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:allowlist_paths).returns([dir])

      transfer = ClusterTransfer.build(action: 'rm', files: ['/home/me/a'], src_fs: 'remote', dest_fs: 'remote')

      assert transfer.valid?, transfer.errors.full_messages.join('. ')
    end
  end

  test 'upload is invalid when the local files are not in the allowlist' do
    Dir.mktmpdir do |allowed|
      Dir.mktmpdir do |dir|
        Configuration.stubs(:allowlist_paths).returns([allowed])
        FileUtils.touch(["#{allowed}/a", "#{dir}/b"])
        @adapter.stubs(:ls).returns([])

        transfer = ClusterTransfer.build(action: 'cp',
                                         files:  { "#{allowed}/a" => '/home/me/a', "#{dir}/b" => '/home/me/b' },
                                         src_fs: 'fs', dest_fs: 'remote')

        assert_not transfer.valid?
        assert_equal ["#{dir}/b is not included under ALLOWLIST_PATH"], transfer.errors.full_messages
      end
    end
  end

  test 'download is invalid when the local destinations are not in the allowlist' do
    Dir.mktmpdir do |allowed|
      Dir.mktmpdir do |dir|
        Configuration.stubs(:allowlist_paths).returns([allowed])

        transfer = ClusterTransfer.build(action: 'cp',
                                         files:  { '/home/me/a' => "#{allowed}/a", '/home/me/b' => "#{dir}/b" },
                                         src_fs: 'remote', dest_fs: 'fs')

        assert_not transfer.valid?
        assert_equal ["#{dir}/b is not included under ALLOWLIST_PATH"], transfer.errors.full_messages
      end
    end
  end

  test 'cluster paths are not checked against the allowlist' do
    Dir.mktmpdir do |allowed|
      Configuration.stubs(:allowlist_paths).returns([allowed])
      @adapter.stubs(:ls).returns([])

      transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/home/me/dir/a' }, src_fs: 'remote',
                                       dest_fs: 'remote')

      assert transfer.valid?, transfer.errors.full_messages.join('. ')
    end
  end

  test 'steps for an upload are the sizes of the local files' do
    Dir.mktmpdir do |dir|
      File.write("#{dir}/a", 'a' * 10)
      File.write("#{dir}/b", 'b' * 20)

      transfer = ClusterTransfer.build(action: 'cp', files: { "#{dir}/a" => '/home/me/a', "#{dir}/b" => '/home/me/b' },
                                       src_fs: 'fs', dest_fs: 'remote')

      assert_equal 30, transfer.steps
    end
  end

  test 'steps for a download are the sizes of the files on the cluster' do
    @adapter.stubs(:size).with('/home/me/a').returns(10)
    @adapter.stubs(:size).with('/home/me/b').returns(20)

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a', '/home/me/b' => '/tmp/b' },
                                     src_fs: 'remote', dest_fs: 'fs')

    assert_equal 30, transfer.steps
  end

  test 'steps for a remove are 100 for each file' do
    @adapter.expects(:size).never

    transfer = ClusterTransfer.build(action: 'rm', files: ['/home/me/a', '/home/me/b'], src_fs: 'remote',
                                     dest_fs: 'remote')

    assert_equal 200, transfer.steps
  end

  test 'steps count files whose size cannot be read as empty' do
    @adapter.stubs(:size).with('/home/me/a').returns(10)
    @adapter.stubs(:size).with('/home/me/missing').raises(StandardError, 'No such file or directory')

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a', '/home/me/missing' => '/tmp/b' },
                                     src_fs: 'remote', dest_fs: 'fs')

    assert_equal 10, transfer.steps
    assert_equal 0, transfer.filesizes['/home/me/missing'][:size]
  end

  test 'update_progress adds up the progress of each file' do
    @adapter.stubs(:size).with('/home/me/a').returns(100)
    @adapter.stubs(:size).with('/home/me/b').returns(300)

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a', '/home/me/b' => '/tmp/b' },
                                     src_fs: 'remote', dest_fs: 'fs')
    transfer.steps

    transfer.update_progress('/home/me/a', 50)
    assert_equal 50, transfer.transferred
    assert_equal 12, transfer.percent

    transfer.update_progress('/home/me/a', 100)
    assert_equal 100, transfer.transferred
    assert_equal 25, transfer.percent

    transfer.update_progress('/home/me/b', 50)
    assert_equal 250, transfer.transferred
    assert_equal 62, transfer.percent

    transfer.update_progress('/home/me/b', 100)
    assert_equal 400, transfer.transferred
    assert_equal 100, transfer.percent
  end

  test 'perform writes an upload to the cluster and removes the tempfile' do
    tempfile = Tempfile.new('upload')
    tempfile.write('a' * 100)
    tempfile.flush

    @adapter.expects(:move_with_progress).never
    @adapter.expects(:write)
            .with('/home/me/dir/a', all_of(instance_of(File), responds_with(:path, tempfile.path)))
            .multiple_yields([50], [100])

    transfer = ClusterTransfer.build(action: 'mv', files: { tempfile.path => '/home/me/dir/a' }, src_fs: 'fs',
                                     dest_fs: 'remote', tempfile: tempfile)
    transfer.perform

    assert transfer.errors.empty?, transfer.errors.full_messages.join('. ')
    assert transfer.status.completed?
    assert_equal 100, transfer.transferred
    assert tempfile.closed?
    assert_nil tempfile.path
  ensure
    tempfile&.close(true)
  end

  test 'perform removes the tempfile when writing an upload fails' do
    tempfile = Tempfile.new('upload')
    upload_path = tempfile.path
    @adapter.stubs(:write).raises(StandardError, 'Could not write /home/me/a: dd: Permission denied')

    transfer = ClusterTransfer.build(action: 'mv', files: { upload_path => '/home/me/a' }, src_fs: 'fs',
                                     dest_fs: 'remote', tempfile: tempfile)
    transfer.perform

    assert_equal ["Error when transferring #{upload_path}: Could not write /home/me/a: dd: Permission denied"],
                 transfer.errors.full_messages
    assert_nil tempfile.path
  ensure
    tempfile&.close(true)
  end

  test 'perform moves files' do
    @adapter.stubs(:size).returns(1)
    @adapter.expects(:move_with_progress).with(@cluster, @cluster, '/home/me/a', '/home/me/dir/a')

    transfer = ClusterTransfer.build(action: 'mv', files: { '/home/me/a' => '/home/me/dir/a' }, src_fs: 'remote',
                                     dest_fs: 'remote')
    transfer.perform

    assert transfer.errors.empty?, transfer.errors.full_messages.join('. ')
  end

  test 'perform copies files' do
    @adapter.stubs(:size).returns(1)
    @adapter.expects(:copy_with_progress).with(@cluster, 'fs', '/home/me/a', '/tmp/a').yields(100)

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a' }, src_fs: 'remote',
                                     dest_fs: 'fs')
    transfer.perform

    assert transfer.errors.empty?, transfer.errors.full_messages.join('. ')
    assert_equal 1, transfer.transferred
  end

  test 'perform removes files' do
    @adapter.expects(:remove_with_progress).with('/home/me/a').yields(100)

    transfer = ClusterTransfer.build(action: 'rm', files: ['/home/me/a'], src_fs: 'remote', dest_fs: 'remote')
    transfer.perform

    assert transfer.errors.empty?, transfer.errors.full_messages.join('. ')
    assert_equal 100, transfer.transferred
  end

  test 'perform transfers the other files when one fails' do
    @adapter.stubs(:size).returns(1)
    @adapter.expects(:copy_with_progress).with(@cluster, 'fs', '/home/me/a', '/tmp/a')
            .raises(StandardError, 'Permission denied')
    @adapter.expects(:copy_with_progress).with(@cluster, 'fs', '/home/me/b', '/tmp/b')

    transfer = ClusterTransfer.build(action: 'cp', files: { '/home/me/a' => '/tmp/a', '/home/me/b' => '/tmp/b' },
                                     src_fs: 'remote', dest_fs: 'fs')
    transfer.perform

    assert_equal ['Error when transferring /home/me/a: Permission denied'], transfer.errors.full_messages
    assert transfer.status.completed?
  end

  test 'perform fails for an unknown action' do
    @adapter.expects(:size).never

    transfer = ClusterTransfer.build(action: 'ln', files: { '/home/me/a' => '/home/me/b' }, src_fs: 'remote',
                                     dest_fs: 'remote')
    transfer.perform

    assert_equal ['Unknown action: "ln"'], transfer.errors.full_messages
    assert transfer.status.completed?
  end
end
