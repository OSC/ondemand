# frozen_string_literal: true

require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test 'should get not_found resource' do
    get '/404'
    assert_response :success
  end

  test 'should get internal_server_error resource' do
    get '/500'
    assert_response :success
  end
end
