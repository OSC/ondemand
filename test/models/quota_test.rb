require 'test_helper'

class QuotaTest < ActiveSupport::TestCase
  setup do
    @quota_defaults = {
      type: "fileset",
      path: "/users/efranz",
      user: "efranz",
      resource_type: "file",
      user_usage: 10,
      total_usage: 50,
      limit: 100,
      grace: 0, # if nil, the params will remove this
      updated_at: Time.now
    }
  end

  test "creating files quota instance for a fileset path" do
    quota = Quota.new(@quota_defaults)

    assert quota.valid?
    assert_equal 10, quota.percent_user_usage
    assert_equal 50, quota.percent_total_usage
    assert quota.sufficient?
    refute quota.insufficient?
    refute quota.sufficient?(threshold: 0.09)
    assert_equal "Using 50 files of quota 100 files (10 files are yours)", quota.to_s
  end

  test "quota invalid with limit 0" do
    quota = Quota.new(@quota_defaults.merge(limit: 0))
    refute quota.valid?

    assert_equal 0, quota.percent_user_usage, "an invalid quota should return 0% usage"
    assert_equal 0, quota.percent_total_usage, "an invalid quota should return 0% usage"

    assert quota.sufficient?, "an invalid quota should not be flagged as insufficient"
    refute quota.insufficient?, "an invalid quota should not be flagged as insufficient"

    assert_equal "Using 50 files of quota 0 files (10 files are yours)", quota.to_s
  end
end