# frozen_string_literal: true

require 'performance_test_case'

class BatchConnectPerformanceTest < PerformanceTestCase
  def setup
    stub_sys_apps
    stub_usr_router
    NavConfig.categories_whitelist = false
  end

  test 'index' do
    get '/batch_connect/sessions'
  end
end
