# frozen_string_literal: true

require 'test_helper'

class InsufficientBalanceTest < ActionDispatch::IntegrationTest
  TIMESTAMP = 1_567_190_705

  def setup
    stub_user
  end

  test 'balance warning last update uses server local time' do
    with_balance_file([{ project: 'PZS0708', user: 'me', value: 0 }]) do |path|
      with_modified_env('OOD_BALANCE_PATH' => path, 'OOD_BALANCE_THRESHOLD' => '10') do
        get '/'
        assert_response :success

        expected_time = Time.at(TIMESTAMP).localtime.strftime('%Y/%m/%d at %l:%M%p')

        assert_select '.insufficient-balance .insufficient-balance-resource', 1
        assert_select 'time[data-local]', count: 0
        assert_includes response.body, expected_time
        assert_includes response.body, I18n.t(
          'dashboard.balance_reload_message_html',
          last_update: expected_time
        )
      end
    end
  end

  private

  def with_balance_file(balances)
    Tempfile.open(%w[balance .json]) do |file|
      file.write({ version: 1, timestamp: TIMESTAMP, balances: balances }.to_json)
      file.flush
      yield file.path
    end
  end
end
