require 'html_helper'
require 'test_helper'

# Test the new radio button functionality in the Jupyter Job Form
# Testing that radio button with value 0 exists
# Testing that radio button with value 1 exists
# Testing that radio button label exists

class BatchConnectTest < ActionDispatch::IntegrationTest

  def setup
    stub_sys_apps
  end

  test 'batch_connect_session_context_mode_0 exists in' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'form input[id="batch_connect_session_context_mode_0"]'   
  end 


  test 'batch_connect_session_context_mode_1 exists in' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'form input[id="batch_connect_session_context_mode_1"]'   
  end 

  test 'label for batch_connect_session_context_mode exists in' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'label[for="batch_connect_session_context_mode"]'   
  end 

end