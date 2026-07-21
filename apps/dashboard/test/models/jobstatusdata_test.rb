# frozen_string_literal: true

require 'test_helper'
require 'active_jobs/jobstatusdata'

class JobstatusdataTest < ActiveSupport::TestCase
  class FakeStatus
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def ==(other)
      state == other
    end
  end

  def build_info(wallclock_limit:, native: {})
    Struct.new(:id, :job_name, :job_owner, :accounting_id, :status, :queue_name, :gpus, :wallclock_time,
               :dispatch_time, :allocated_nodes, :wallclock_limit, :native, keyword_init: true).new(
      id: '123',
      job_name: 'Test Job',
      job_owner: 'user',
      accounting_id: 'acct',
      status: FakeStatus.new(:queued),
      queue_name: 'normal',
      gpus: 0,
      wallclock_time: 3600,
      dispatch_time: 1_700_000_000,
      allocated_nodes: [],
      wallclock_limit: wallclock_limit,
      native: native
    )
  end

  def build_jobstatusdata
    job = ActiveJobs::Jobstatusdata.allocate
    job.send(:pbsid=, '123')
    job.send(:jobname=, 'Test Job')
    job.send(:username=, 'user')
    job.send(:account=, 'acct')
    job.send(:cluster=, 'oakley')
    job.send(:cluster_title=, 'Oakley')
    job.send(:nodes=, [])
    job.send(:queue=, 'normal')
    job.send(:output_path=, '/tmp')
    job
  end

  test 'extended data uses wallclock_limit for walltime values' do
    info = build_info(
      wallclock_limit: '02:00:00',
      native: {
        Resource_List: { walltime: '01:00:00', nodect: 2, nodes: 'nodes=2:ppn=8' },
        resources_used: { cput: '00:10:00', mem: '1 gb', vmem: '2 gb' },
        comment: 'comment',
        Output_Path: '/tmp'
      }
    )

    torque_job = build_jobstatusdata
    torque_job.extended_data_torque(info)
    assert_equal '02:00:00', torque_job.native_attribs.find { |a| a.name == 'Walltime' }.value

    slurm_job = build_jobstatusdata
    slurm_job.extended_data_slurm(
      build_info(
        wallclock_limit: '03:00:00',
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
    )
    assert_equal '03:00:00', slurm_job.native_attribs.find { |a| a.name == 'Time Limit' }.value

    lsf_job = build_jobstatusdata
    lsf_job.extended_data_lsf(
      build_info(
        wallclock_limit: '04:00:00',
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
    )
    assert_equal '04:00:00', lsf_job.native_attribs.find { |a| a.name == 'Walltime' }.value

    pbspro_job = build_jobstatusdata
    pbspro_job.extended_data_pbspro(
      build_info(
        wallclock_limit: '05:00:00',
        native: {
          Resource_List: { walltime: '01:00:00', nodect: 2, ncpus: 4, select: '1:ncpus=4' },
          resources_used: { cput: '00:10:00', mem: '1 gb', vmem: '2 gb' },
          group_list: 'group',
          comment: 'comment',
          Submit_arguments: 'arg',
          Output_Path: '/tmp/out'
        }
      )
    )
    assert_equal '05:00:00', pbspro_job.native_attribs.find { |a| a.name == 'Walltime' }.value
  end
end
