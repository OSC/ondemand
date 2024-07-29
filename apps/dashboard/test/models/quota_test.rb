require 'test_helper'
require 'net/http'

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
    assert quota.send(:limit_invalid?, 'not a limit'), '"not a limit" is not a a valid limit'
    assert quota.send(:limit_invalid?, -1), 'negative numbers are not valid limits'

    refute quota.send(:limit_invalid?, 5), 'Quota should not warn if limit is a positive integer'
    refute quota.send(:limit_invalid?, 'unlimited'), 'Quota should not warn if limit is "unlimited"'
    refute quota.send(:limit_invalid?, nil), 'Quota should not warn if limit is nil'
  end

  test "invalid version handles InvalidQuotaFile exception" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 2000}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz')
    end
  end

  test "handles InvalidQuotaFile exception for invalid json" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz')
    end
  end

  test "handles InvalidQuotaFile exception for json with missing quotas array " do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 1}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz')
    end
  end

  test "handles InvalidQuotaFile exception for json array" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('[]')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz')
    end
  end

  test "handles KeyError for quota with missing path" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 1, "quotas": [ { "user":"efranz" }]}')

      assert_equal [], Quota.find(quota_file, 'efranz')
    end
  end

  test "loading fixtures from file" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"
    quotas = Quota.find(quota_file, 'efranz')

    assert_equal 4, quotas.count, "Should have found 4 quotas. The json file specifies 2 quota hashes, for 4 quotas - 2 file and 2 block quotas"

    file_quota = quotas.find {|q| q.path.to_s == "/users/PND0005" }
    assert file_quota, "Failed to find file quota for efranz and path /users/PND0005 in fixture"
    assert_equal 973, file_quota.total_usage
    assert_equal "file", file_quota.resource_type
    assert_equal 1000000, file_quota.limit
  end

  test "loading fixtures from URL" do
    quota_file = Pathname.new("#{Rails.root}/test/fixtures/quota.json").read
    # stub open with an object you can call read on
    Net::HTTP.stubs(:get).returns(quota_file)
    quotas = Quota.find("https://url/to/quota.json", 'efranz')

    assert_equal 4, quotas.count, "Should have found 4 quotas. The json file specifies 2 quota hashes, for 4 quotas - 2 file and 2 block quotas"
    file_quota = quotas.find {|q| q.path.to_s == "/users/PND0005" }
    assert file_quota, "Failed to find file quota for efranz and path /users/PND0005 in fixture"
    assert_equal 973, file_quota.total_usage
    assert_equal "file", file_quota.resource_type
    assert_equal 1000000, file_quota.limit
  end

  test "handle error loading URL" do
    Net::HTTP.stubs(:get).raises(StandardError, "404 file not found")
    quotas = Quota.find("https://url/to/quota.json", 'efranz')

    assert_equal [], quotas, "Should have handled exception and returned 0 quotas"
  end

  test "per quota timestamp" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    # per quota timestamp
    quotas = Quota.find(quota_file, 'djohnson')
    assert_equal 1546456000, quotas.first.updated_at.to_i

    # global timestamp
    quotas = Quota.find(quota_file, 'efranz')
    assert_equal 1546455993, quotas.first.updated_at.to_i
  end
end
