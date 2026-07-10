require 'test_helper'

class BalanceWarningsViewsTest < ActionDispatch::IntegrationTest
  setup do
    stub_user
    stub_user_configuration({})
  end

  test 'shows informational message when there are no balance warnings' do
    with_balance_file([{ project: 'PZS0708', user: 'me', value: 20 }]) do |path|
      with_modified_env('OOD_BALANCE_PATH' => path, 'OOD_BALANCE_THRESHOLD' => '10') do
        get '/'
        assert_response :success
        assert_select 'div.alert.alert-info.insufficient-balance'
      end
    end
  end

  test 'shows danger alert when there is a balance warning' do
    with_balance_file([{ project: 'PZS0708', user: 'me', value: 0 }]) do |path|
      with_modified_env('OOD_BALANCE_PATH' => path, 'OOD_BALANCE_THRESHOLD' => '10') do
        get '/'
        assert_response :success
        assert_select 'div.alert.alert-danger.insufficient-balance'
      end
    end
  end

  private

  def with_balance_file(balances)
    Tempfile.open(%w[balance .json]) do |f|
      f.write(
        {
          version: 1,
          timestamp: 1234567890,
          config: { unit: 'RU', project_type: 'project' },
          balances: balances
        }.to_json
      )
      f.flush

      yield f.path
    end
  end
end