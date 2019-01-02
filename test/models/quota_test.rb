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

    assert quota.limited?
    assert_equal 10, quota.percent_user_usage
    assert_equal 50, quota.percent_total_usage
    assert quota.sufficient?
    refute quota.insufficient?
    refute quota.sufficient?(threshold: 0.09)
    assert_equal "Using 50 files of quota 100 files (10 files are yours)", quota.to_s
  end

  test "quota unlimited when limit is 0" do
    quota = Quota.new(@quota_defaults.merge(limit: 0))
    refute quota.limited?

    assert_equal 0, quota.percent_user_usage, "an unlimited quota should return 0% usage"
    assert_equal 0, quota.percent_total_usage, "an unlimited quota should return 0% usage"

    assert quota.sufficient?, "an unlimited quota should not be flagged as insufficient"
    refute quota.insufficient?, "an unlimited quota should not be flagged as insufficient"

    assert_equal "Using 50 files of quota 0 files (10 files are yours)", quota.to_s
  end

  test "quota warns only when limit is invalid" do
    # Note that this should log an error about the limit being invalid
    quota = Quota.new(@quota_defaults.merge(limit: 'not a limit'))
    assert quota.send(:invalid?, 'not a limit'), '"not a limit" is not a a valid limit'
    assert quota.send(:invalid?, -1), 'negative numbers are not valid limits'

    refute quota.send(:invalid?, 5), 'Quota should not warn if limit is a positive integer'
    refute quota.send(:invalid?, 'unlimited'), 'Quota should not warn if limit is "unlimited"'
    refute quota.send(:invalid?, nil), 'Quota should not warn if limit is nil'
  end

  test "invalid version raises InvalidQuotaFile exception" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 2000}')

      assert_raises Quota::InvalidQuotaFile do
        Quota.find(quota_file, 'efranz')
      end
    end
  end

  test "invalid json raises InvalidQuotaFile exception" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{}')

      assert_raises Quota::InvalidQuotaFile do
        Quota.find(quota_file, 'efranz')
      end
    end
  end
end
