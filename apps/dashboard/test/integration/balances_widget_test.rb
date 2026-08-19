# frozen_string_literal: true

require 'test_helper'

class BalancesWidgetTest < ActionDispatch::IntegrationTest
  def setup
    stub_user
    stub_user_configuration({
      dashboard_layout: {
        rows: [{ columns: [{ width: 12, widgets: ['balances'] }] }]
      }
    })
  end

  test 'shows a message when there are no balances' do
    with_modified_env('OOD_BALANCE_PATH' => '', 'OOD_BALANCE_THRESHOLD' => '10') do
      get '/'
      assert_response :success
      assert_select 'ul.list-group li.list-group-item',
        I18n.t('dashboard.balance_no_warnings', threshold: 10)
    end
  end

  test 'shows balances when they exist' do
    with_balance_file([{ project: 'PZS0708', user: 'me', value: 20 }]) do |path|
      with_modified_env('OOD_BALANCE_PATH' => path) do
        get '/'
        assert_response :success
        assert_select 'ul.list-group li.list-group-item', /PZS0708/
        assert_select 'ul.list-group li.list-group-item',
          text:  I18n.t('dashboard.balance_no_warnings', threshold: Configuration.balance_threshold.to_i),
          count: 0
      end
    end
  end

  private

  def with_balance_file(balances)
    Tempfile.open(%w[balance .json]) do |file|
      file.write({ version: 1, timestamp: 1_567_190_705, balances: balances }.to_json)
      file.flush
      yield file.path
    end
  end
end
