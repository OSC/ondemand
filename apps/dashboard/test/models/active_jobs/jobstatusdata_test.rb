require 'test_helper'
require 'active_jobs/jobstatusdata'

class ActiveJobs::JobstatusdataTest < ActiveSupport::TestCase
  def setup
    clusters = OodCore::Clusters.load_file('test/fixtures/config/clusters.d')
    oakley = clusters['oakley']
    OODClusters.stubs(:[]).with('oakley').returns(oakley)
    OODClusters.stubs(:[]).with(:oakley).returns(oakley)
  end

  test 'slurm extended details include Submission Time from Info#submission_time' do
    submitted_at = Time.local(2024, 6, 15, 14, 30, 0)
    data = ActiveJobs::Jobstatusdata.new(slurm_info(submission_time: submitted_at), 'oakley', true)

    row = data.native_attribs.find { |a| a.name == 'Submission Time' }
    assert_not_nil row
    assert_equal '2024-06-15 14:30:00', row.value
  end

  test 'slurm extended details omit Submission Time when Info#submission_time is missing' do
    data = ActiveJobs::Jobstatusdata.new(slurm_info(submission_time: nil), 'oakley', true)

    assert_nil data.native_attribs.find { |a| a.name == 'Submission Time' }
  end

  test 'torque extended data uses wallclock_limit for walltime' do
    info = build_info(
      wallclock_limit: 7200, # seconds; pretty_time should format this to "02:00:00"
      native: {
        Resource_List: { walltime: '01:00:00', nodect: 2, nodes: 'nodes=2:ppn=8' },
        resources_used: { cput: '00:10:00', mem: '1 gb', vmem: '2 gb' },
        comment: 'comment',
        Output_Path: '/tmp'
      }
    )

    job = build_jobstatusdata(info, 'torque')

    assert_equal '02:00:00', job.native_attribs.find { |a| a.name == 'Walltime' }.value
  end

  test 'slurm extended data uses wallclock_limit for walltime' do
    info = build_info(
      wallclock_limit: 10_800, # seconds -> "03:00:00"
      native: {
        array_job_id: '1',
        array_task_id: '1',
        state: 'RUNNING',
        reason: 'None',
        nodes: 2,
        cpus: 64,
        time_limit: '01:00:00',
        start_time: '2025-08-28T14:00:00',
        end_time: '2025-08-28T15:00:00',
        min_memory: '128GB',
        gres: 'N/A',
        work_dir: '/tmp'
      }
    )

    job = build_jobstatusdata(info, 'slurm')

    assert_equal '03:00:00', job.native_attribs.find { |a| a.name == 'Time Limit' }.value
  end

  test 'lsf extended data uses wallclock_limit for walltime' do
    info = build_info(
      wallclock_limit: 14_400, # seconds -> "04:00:00"
      native: {
        from_host: 'host1',
        exec_host: 'host2',
        project: 'proj',
        cpu_used: '1',
        mem: '2',
        swap: '3',
        pids: '4',
        submit_time: '2025-08-28T14:00:00',
        start_time: '2025-08-28T14:00:00',
        finish_time: '2025-08-28T15:00:00'
      }
    )

    job = build_jobstatusdata(info, 'lsf')

    assert_equal '04:00:00', job.native_attribs.find { |a| a.name == 'Walltime' }.value
  end

  test 'pbspro extended data uses wallclock_limit for walltime' do
    info = build_info(
      wallclock_limit: 18_000, # seconds -> "05:00:00"
      native: {
        Resource_List: { walltime: '01:00:00', nodect: 2, ncpus: 4, select: '1:ncpus=4' },
        resources_used: { cput: '00:10:00', mem: '1 gb', vmem: '2 gb' },
        group_list: 'group',
        comment: 'comment',
        Submit_arguments: 'arg',
        Output_Path: '/tmp/out'
      }
    )

    job = build_jobstatusdata(info, 'pbspro')

    assert_equal '05:00:00', job.native_attribs.find { |a| a.name == 'Walltime' }.value
  end

  test 'walltime falls back to 00:00:00 when wallclock_limit is nil' do
    info = build_info(wallclock_limit: nil, native: { Output_Path: '/tmp' })

    job = build_jobstatusdata(info, 'torque')

    assert_equal '00:00:00', job.native_attribs.find { |a| a.name == 'Walltime' }.value
  end

  private

  def slurm_info(submission_time:)
    OodCore::Job::Info.new(
      id:              '42',
      status:          :queued,
      job_name:        'job',
      job_owner:       'user',
      accounting_id:   'acct',
      queue_name:      'batch',
      wallclock_time:  0,
      submission_time: submission_time,
      native:          {
        work_dir:      Dir.home,
        array_job_id:  '',
        array_task_id: '',
        state:         'PENDING',
        reason:        'Priority',
        nodes:         '1',
        cpus:          '1',
        time_limit:    '01:00:00',
        start_time:    'N/A',
        end_time:      'N/A',
        min_memory:    '1G',
        gres:          'N/A'
      }
    )
  end

  def cluster_double(adapter)
    OodCore::Cluster.new(id: adapter, job: { adapter: adapter })
  end

  def stub_cluster(adapter)
    cluster = cluster_double(adapter)
    OODClusters.stubs(:[]).with(adapter.to_s).returns(cluster)
    OODClusters.stubs(:[]).with(adapter.to_sym).returns(cluster)
    cluster
  end
  
  def build_info(info = {})
  default = {
    id: '123',
    job_name: 'Test Job',
    job_owner: 'user',
    accounting_id: 'acct',
    status: :queued,
    queue_name: 'normal',
    gpus: 0,
    wallclock_time: 3600,
    dispatch_time: 1_700_000_000,
    allocated_nodes: [],
    wallclock_limit: nil,
    native: {}
  }
  OodCore::Job::Info.new(**default.merge(info))
end

  # Goes through the real constructor, letting `initialize` do its own
  # adapter dispatch (extended_data_torque/slurm/lsf/pbspro) rather than
  # calling those methods directly.
  def build_jobstatusdata(info, adapter, extended: true)
    cluster = stub_cluster(adapter)
    ActiveJobs::Jobstatusdata.new(info, cluster.id, extended)
  end
end
