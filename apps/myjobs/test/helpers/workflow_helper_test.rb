require 'test_helper'

class WorkflowsHelperTest < ActionView::TestCase
  test "xdmod url warning message for newly completed job" do
    w = Workflow.new
    w.stubs(:completed_at).returns(Time.now)

    assert_equal I18n.t('jobcomposer.xdmod_url_warning_message'), xdmod_url_warning_message(w)
  end


  test "xdmod url warning message hidden for old job" do
    t = Time.now
    w = Workflow.new
    w.stubs(:completed_at).returns(t)

    Timecop.freeze(t.advance(days: 1)) do
      refute xdmod_url_warning_message(w), "#{Time.now} is 48 hours after #{w.completed_at} so no warning message should display"
    end
  end

  test "xdmod url warning message hidden if localization timespan set to 0" do
    I18n.stubs(:t).with('jobcomposer.xdmod_url_warning_message_seconds_after_job_completion').returns(0)
    I18n.stubs(:t).with('jobcomposer.xdmod_url_warning_message').returns('This message should never display.')

    w = Workflow.new
    w.stubs(:completed_at).returns(Time.now)
    refute xdmod_url_warning_message(w)
  end

  test "xdmod url warning message timespan can be changed" do
    message = 'Display till 9 seconds passed.'
    I18n.stubs(:t).with('jobcomposer.xdmod_url_warning_message_seconds_after_job_completion').returns(9)
    I18n.stubs(:t).with('jobcomposer.xdmod_url_warning_message').returns(message)

    t = Time.now
    w = Workflow.new
    w.stubs(:completed_at).returns(t)

    Timecop.freeze(t.advance(seconds: 8)) do
      assert_equal message, xdmod_url_warning_message(w)
    end

    Timecop.freeze(t.advance(seconds: 9)) do
      refute xdmod_url_warning_message(w)
    end
  end
end
