# frozen_string_literal: true

require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  def setup
    @adapter = stub('file_adapter')
    @clusters = ['cluster1', 'cluster2'].to_h do |id|
      cluster = OodCore::Cluster.new({ id: id, job: { adapter: 'slurm' }, file: { adapter: 'ssh', host: 'login' } })
      cluster.stubs(:file_adapter).returns(@adapter)
      [id, cluster]
    end
    OODClusters.stubs(:[]).returns(nil)
    @clusters.each { |id, cluster| OODClusters.stubs(:[]).with(id.to_sym).returns(cluster) }

    Configuration.stubs(:remote_files_enabled?).returns(true)
    TransferLocalJob.stubs(:perform_later)
  end

  def teardown
    Transfer.transfers.reject! { |t| t.is_a?(ClusterTransfer) }
  end

  def create_transfer(body)
    # CSRF protection is enabled in tests, so send a valid token for the test session.
    @controller.request = @request
    @request.headers['X-CSRF-Token'] = @controller.send(:form_authenticity_token)
    post :create, body: body.to_json, format: :json
    JSON.parse(@response.body)
  end

  test 'upload to a cluster starts a cluster transfer' do
    @adapter.stubs(:ls).with('/home/me').returns([])
    TransferLocalJob.expects(:perform_later).with(instance_of(ClusterTransfer))

    json = create_transfer(command: 'cp', from_fs: 'fs', to_fs: 'cluster1', files: { '/tmp/a' => '/home/me/a' })

    assert_response :success
    assert_nil json['error_message']
    assert_equal '/home/me', json['target_dir']
    transfer = Transfer.find(json['id'])
    assert_kind_of ClusterTransfer, transfer
    assert_equal 'fs', transfer.src_fs
    assert_equal @clusters['cluster1'], transfer.dest_fs
  end

  test 'download from a cluster starts a cluster transfer' do
    TransferLocalJob.expects(:perform_later).with(instance_of(ClusterTransfer))

    Dir.mktmpdir do |dir|
      json = create_transfer(command: 'cp', from_fs: 'cluster1', to_fs: 'fs', files: { '/home/me/a' => "#{dir}/a" })

      assert_nil json['error_message']
      assert_kind_of ClusterTransfer, Transfer.find(json['id'])
    end
  end

  test 'transfer within a cluster starts a cluster transfer' do
    TransferLocalJob.expects(:perform_later).with(instance_of(ClusterTransfer))

    json = create_transfer(command: 'rm', from_fs: 'cluster1', to_fs: 'cluster1', files: ['/home/me/a'])

    assert_nil json['error_message']
    assert_kind_of ClusterTransfer, Transfer.find(json['id'])
  end

  test 'invalid cluster transfer returns the validation errors' do
    @adapter.stubs(:ls).returns([{ name: 'a' }])
    TransferLocalJob.expects(:perform_later).never

    json = create_transfer(command: 'cp', from_fs: 'fs', to_fs: 'cluster1', files: { '/tmp/a' => '/home/me/a' })

    assert_equal({ 'error_message' => 'These files already exist: /home/me/a' }, json)
  end

  test 'transfers between different clusters are not supported' do
    ClusterTransfer.expects(:build).never

    json = create_transfer(command: 'cp', from_fs: 'cluster1', to_fs: 'cluster2', files: { '/a' => '/b' })

    assert_equal({ 'error_message' => 'Transfers between different clusters are not supported' }, json)
  end

  test 'transfers between a cluster and a remote are not supported' do
    ClusterTransfer.expects(:build).never
    RemoteTransfer.expects(:build).never

    [['cluster1', 'myremote'], ['myremote', 'cluster1']].each do |from_fs, to_fs|
      json = create_transfer(command: 'cp', from_fs: from_fs, to_fs: to_fs, files: { '/a' => '/b' })

      assert_equal({ 'error_message' => 'Remote file transfers from or to clusters are not supported' }, json)
    end
  end
end
