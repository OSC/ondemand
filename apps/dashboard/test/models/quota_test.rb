require 'test_helper'
require 'net/http'

class QuotaTest < ActiveSupport::TestCase
  setup do
    @quota_defaults = {
      type:          "fileset",
      path:          "/users/efranz",
      user:          "efranz",
      resource_type: "file",
      user_usage:    10,
      total_usage:   50,
      limit:         100,
      grace:         0, # if nil, the params will remove this
      updated_at:    Time.now
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
    assert_equal :fileset, quota.type
    assert quota.shared?
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
      assert_equal [], Quota.find(quota_file, 'efranz', ['efranz'])
    end
  end

  test "handles InvalidQuotaFile exception for invalid json" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz', ['efranz'])
    end
  end

  test "handles InvalidQuotaFile exception for json with missing quotas array " do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 1}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz', ['efranz'])
    end
  end

  test "handles InvalidQuotaFile exception for json array" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('[]')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidQuotaFile/))
      assert_equal [], Quota.find(quota_file, 'efranz', ['efranz'])
    end
  end

  test "handles KeyError for quota with missing path" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write('{"version": 1, "quotas": [ { "user":"efranz" }]}')

      assert_equal [], Quota.find(quota_file, 'efranz', ['efranz'])
    end
  end

  test "loading fixtures from file includes group quotas" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"
    quotas = Quota.find(quota_file, 'efranz', ['efranz', 'efranz_group'])

    # User quotas (2 file + 2 block for efranz) + group quotas (1 file + 1 block for efranz_group)
    assert_equal 6, quotas.count, "Should have found 6 quotas: 4 user quotas and 2 group quotas"

    file_quota = quotas.find { |q| q.path.to_s == "/users/PND0005" }
    assert file_quota, "Failed to find file quota for efranz and path /users/PND0005 in fixture"
    assert_equal 973, file_quota.total_usage
    assert_equal "file", file_quota.resource_type
    assert_equal 1000000, file_quota.limit

    # Verify group quotas are included
    group_quotas = quotas.select { |q| q.type == :group }
    assert_equal 2, group_quotas.count, "Should have 2 group quotas (1 file + 1 block for efranz_group)"

    # Verify the efranz_group quota from fixtures
    group_file_quota = group_quotas.find { |q| q.path.to_s == "/users/PAN0014" && q.resource_type == 'file' }
    assert group_file_quota, "Failed to find group quota for efranz_group and path /users/PAN0014"
    assert_equal :group, group_file_quota.type
    assert_equal 10000, group_file_quota.total_usage
    assert_equal 10000, group_file_quota.user_usage
    assert_equal 500000, group_file_quota.limit
    assert group_file_quota.shared?
    assert_equal "efranz_group", group_file_quota.user

    group_block_quota = group_quotas.find { |q| q.path.to_s == "/users/PAN0014" && q.resource_type == 'block' }
    assert group_block_quota, "Failed to find group block quota for efranz_group and path /users/PAN0014"
    assert_equal :group, group_block_quota.type
    assert_equal 2500000, group_block_quota.total_usage
    assert_equal 2500000, group_block_quota.user_usage
    assert_equal 5368709120, group_block_quota.limit
    assert group_block_quota.shared?
  end

  test "loading fixtures from URL includes group quotas" do
    quota_file = Pathname.new("#{Rails.root}/test/fixtures/quota.json").read
    # stub open with an object you can call read on
    Net::HTTP.stubs(:get).returns(quota_file)
    quotas = Quota.find("https://url/to/quota.json", 'efranz', ['efranz', 'efranz_group'])

    assert_equal 6, quotas.count, "Should have found 6 quotas: 4 user quotas and 2 group quotas"
    file_quota = quotas.find { |q| q.path.to_s == "/users/PND0005" }
    assert file_quota, "Failed to find file quota for efranz and path /users/PND0005 in fixture"
    assert_equal 973, file_quota.total_usage
    assert_equal "file", file_quota.resource_type
    assert_equal 1000000, file_quota.limit

    # Verify group quotas are included
    group_quotas = quotas.select { |q| q.type == :group }
    assert_equal 2, group_quotas.count, "Should have 2 group quotas (1 file + 1 block for efranz_group)"

    # Verify the efranz_group quota from fixtures
    group_file_quota = group_quotas.find { |q| q.path.to_s == "/users/PAN0014" && q.resource_type == 'file' }
    assert group_file_quota, "Failed to find group quota for efranz_group and path /users/PAN0014"
    assert_equal :group, group_file_quota.type
    assert_equal 10000, group_file_quota.total_usage
    assert_equal 500000, group_file_quota.limit
  end

  test "handle error loading URL" do
    Net::HTTP.stubs(:get).raises(StandardError, "404 file not found")
    quotas = Quota.find("https://url/to/quota.json", 'efranz', ['efranz'])

    assert_equal [], quotas, "Should have handled exception and returned 0 quotas"
  end

  test "per quota timestamp" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    # per quota timestamp
    quotas = Quota.find(quota_file, 'djohnson', ['djohnson'])
    assert_equal 2, quotas.count, "Should have 2 quotas (file and block) for djohnson"
    assert_equal 1546456000, quotas.first.updated_at.to_i

    # global timestamp
    quotas = Quota.find(quota_file, 'efranz', ['efranz', 'efranz_group'])
    # efranz's user quotas should use global timestamp
    user_quotas = quotas.select { |q| q.user == 'efranz' && q.type == :user }
    assert user_quotas.any?
    assert_equal 1546455993, user_quotas.first.updated_at.to_i
  end

  test "group quotas only returned for user's groups" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    # User who is only in PZS0720 group (not in efranz_group)
    quotas = Quota.find(quota_file, 'testuser', ['PZS0720'])

    # Should only return quotas for PZS0720 group (2 quotas: file and block)
    assert_equal 2, quotas.count
    assert quotas.all? { |q| q.user == 'PZS0720' }
    assert quotas.all? { |q| q.type == :group }

    # Verify the PZS0720 quota values from fixtures
    file_quota = quotas.find { |q| q.resource_type == 'file' && q.user == 'PZS0720' }
    assert file_quota, "Failed to find file quota for PZS0720"
    assert_equal 566201, file_quota.total_usage
    assert_equal 566201, file_quota.user_usage
    assert_equal 1000000, file_quota.limit
    assert_equal "/fs/project", file_quota.path.to_s

    block_quota = quotas.find { |q| q.resource_type == 'block' }
    assert block_quota, "Failed to find block quota for PZS0720"
    assert_equal 10534483488, block_quota.total_usage
    assert_equal 10534483488, block_quota.user_usage
    assert_equal 10737418240, block_quota.limit
  end

  test "group quota type is :group" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    quotas = Quota.find(quota_file, 'testuser', ['efranz_group'])

    assert quotas.all? { |q| q.type == :group }
    assert quotas.all? { |q| q.shared? }

    # Verify the efranz_group quota has correct type
    group_quota = quotas.find { |q| q.user == 'efranz_group' }
    assert_equal :group, group_quota.type
    assert_equal 'efranz_group', group_quota.user
  end

  test "group quota returns empty when user has no matching groups" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    quotas = Quota.find(quota_file, 'testuser', ['different_group'])

    # User should only get their user quotas, not any group quotas
    # Since testuser is not in any matching groups, no group quotas should be returned
    # and there are no user quotas for testuser in the fixture
    assert_equal 0, quotas.count, "Should return no quotas when user has no matching groups"
  end

  test "group quota handles missing quotas_other array" do
    Dir.mktmpdir do |dir|
      quota_file = Pathname.new(dir).join('quota.json')
      quota_file.write({
        "quotas"    => [],
        "timestamp" => 1546455993
      }.to_json)

      quotas = Quota.find(quota_file, 'testuser', ['test_group'])

      assert_equal 0, quotas.count
    end
  end

  test "group quota display format from fixture" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    quotas = Quota.find(quota_file, 'testuser', ['PZS0720'])

    file_quota = quotas.find { |q| q.resource_type == 'file' && q.type == :group }
    block_quota = quotas.find { |q| q.resource_type == 'block' && q.type == :group }

    assert file_quota, "Should find file quota for PZS0720"
    assert block_quota, "Should find block quota for PZS0720"

    # Verify the string representation includes usage info
    assert_equal "Group PZS0720 using 566 thousand files of quota 1 million files", file_quota.to_s
    assert_equal "Group PZS0720 using 9.81 TB of quota 10 TB", block_quota.to_s
    assert file_quota.shared?, "Group file quota should be shared"
    assert block_quota.shared?, "Group block quota should be shared"
  end

  test "group quota works without groups parameter (backward compatibility)" do
    quota_file = Pathname.new "#{Rails.root}/test/fixtures/quota.json"

    # Call without groups parameter (defaults to empty array)
    quotas = Quota.find(quota_file, 'efranz')

    # Should only return user quotas, no group quotas
    assert_equal 4, quotas.count, "Should have found 4 user quotas"
    assert quotas.all? { |q| q.type == :user }
  end
end
