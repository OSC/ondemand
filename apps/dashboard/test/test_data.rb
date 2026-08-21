module TestData

  def accounts(cluster: 'owens')
    [
      OodCore::Job::AccountInfo.new(name: 'no-qos', cluster: cluster),
      OodCore::Job::AccountInfo.new(name: 'has-qos1', cluster: cluster, qos: ['qos1']),
      OodCore::Job::AccountInfo.new(name: 'has-qos2', cluster: cluster, qos: ['qos2']),
      OodCore::Job::AccountInfo.new(name: 'has-qos12', cluster: cluster, qos: ['qos1', 'qos2'])
    ]
  end

  def queues
    [
      OodCore::Job::QueueInfo.new(name: 'allow-all-deny-none'),
      OodCore::Job::QueueInfo.new(name: 'allow-qos1', allow_qos: ['qos1']),
      OodCore::Job::QueueInfo.new(name: 'deny-qos2', deny_qos: ['qos2']),
      OodCore::Job::QueueInfo.new(name: 'allow-qos1-deny-qos2', allow_qos: ['qos1'], deny_qos: ['qos2']),
    ]
  end

  def owens_cluster
    OodCore::Cluster.new(
      id: 'owens', 
      job: { adapter: 'slurm' },
      login: { host: 'example.host' }
    )
  end
end