require 'test_helper'

class ActiveJobs::JobstatusdataTest < ActiveSupport::TestCase
  setup do
    @job = ActiveJobs::Jobstatusdata.allocate
  end

  test 'submission_time_display prefers Info#submission_time when set' do
    t = Time.utc(2024, 6, 15, 14, 30, 0)
    info = OpenStruct.new(submission_time: t, native: { submit_time: 'ignored' })

    assert_equal '2024-06-15 14:30:00', @job.send(:submission_time_display, info)
  end

  test 'submission_time_display uses native ACCEPT for Fujitsu-style payloads' do
    info = OpenStruct.new(
      submission_time: nil,
      native: { ACCEPT: '2024-06-15 14:30:00' }
    )

    assert_equal '2024-06-15 14:30:00', @job.send(:submission_time_display, info)
  end

  test 'submission_time_display falls back to native submit_time' do
    info = OpenStruct.new(
      submission_time: nil,
      native: { submit_time: '2024-06-15 14:30:00' }
    )

    assert_equal '2024-06-15 14:30:00', @job.send(:submission_time_display, info)
  end

  test 'submission_time_display returns empty when unknown' do
    info = OpenStruct.new(submission_time: nil, native: {})

    assert_equal '', @job.send(:submission_time_display, info)
  end
end
