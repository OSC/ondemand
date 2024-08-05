require 'test_helper'
require 'net/http'

class BalanceTest < ActiveSupport::TestCase
  setup do
    @balance_defaults = {
      user: "ood",
      project: "ood-group",
      value: 0,
      unit: "RU",
      updated_at: Time.now
    }
  end

  test "creating files balance instance for a fileset path" do
    balance = Balance.new(@balance_defaults)

    assert_equal "ood-group", balance.balance_object
    refute balance.sufficient?
    assert balance.insufficient?
    refute balance.sufficient?(threshold: 5)
    assert_equal "RU balance is 0", balance.to_s
  end

  test "creating files balance instance for a fileset path without project" do
    @balance_defaults.delete(:project)
    balance = Balance.new(@balance_defaults)

    assert_equal "ood", balance.balance_object
    refute balance.sufficient?
    assert balance.insufficient?
    refute balance.sufficient?(threshold: 5)
    assert_equal "RU balance is 0", balance.to_s
  end

  test "invalid version handles InvalidBalanceFile exception" do
    Dir.mktmpdir do |dir|
      balance_file = Pathname.new(dir).join('balance.json')
      balance_file.write('{"version": 2000}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidBalanceFile/))
      assert_equal [], Balance.find(balance_file, 'ood')
    end
  end

  test "handles InvalidBalanceFile exception for invalid json" do
    Dir.mktmpdir do |dir|
      balance_file = Pathname.new(dir).join('balance.json')
      balance_file.write('{}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidBalanceFile/))
      assert_equal [], Balance.find(balance_file, 'ood')
    end
  end

  test "handles InvalidBalanceFile exception for json with missing balances array " do
    Dir.mktmpdir do |dir|
      balance_file = Pathname.new(dir).join('balance.json')
      balance_file.write('{"version": 1}')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidBalanceFile/))
      assert_equal [], Balance.find(balance_file, 'ood')
    end
  end

  test "handles InvalidBalanceFile exception for json array" do
    Dir.mktmpdir do |dir|
      balance_file = Pathname.new(dir).join('balance.json')
      balance_file.write('[]')

      Rails.logger.expects(:error).with(regexp_matches(/InvalidBalanceFile/))
      assert_equal [], Balance.find(balance_file, 'ood')
    end
  end

  test "handles KeyError for balance with missing path" do
    Dir.mktmpdir do |dir|
      balance_file = Pathname.new(dir).join('balance.json')
      balance_file.write('{"version": 1, "balances": [ { "user":"ood" }]}')

      assert_equal [], Balance.find(balance_file, 'ood')
    end
  end

  test "loading fixtures from file" do
    balance_file = Pathname.new "#{Rails.root}/test/fixtures/balance.json"
    balances = Balance.find(balance_file, 'tdockendorf')

    assert_equal 1, balances.count
    assert_equal 0, balances.first.value
  end

  test "loading fixtures from URL" do
    balance_file = Pathname.new("#{Rails.root}/test/fixtures/balance.json").read
    # stub open with an object you can call read on
    Net::HTTP.stubs(:get).returns(balance_file)
    balances = Balance.find("https://url/to/balance.json", 'tdockendorf')

    assert_equal 1, balances.count
    assert_equal 0, balances.first.value
  end

  test "handle error loading URL" do
    Net::HTTP.stubs(:get).raises(StandardError, "404 file not found")
    balances = Balance.find("https://url/to/balance.json", 'tdockendorf')

    assert_equal [], balances, "Should have handled exception and returned 0 balances"
  end

  test "per balance timestamp" do
    balance_file = Pathname.new "#{Rails.root}/test/fixtures/balance.json"

    # per balance timestamp
    balances = Balance.find(balance_file, 'djohnson')
    assert_equal 1567190705, balances.first.updated_at.to_i

    # global timestamp
    balances = Balance.find(balance_file, 'efranz')
    assert_equal 1567190705, balances.first.updated_at.to_i
  end
end
