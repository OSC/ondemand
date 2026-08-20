require 'test_helper'

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
end
