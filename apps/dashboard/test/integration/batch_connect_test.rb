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

  test 'radio buttons and labels appear correctly' do
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'form input[id="batch_connect_session_context_mode_0"]' 

    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_select 'form input[id="batch_connect_session_context_mode_1"]'   
    
    get new_batch_connect_session_context_url('sys/bc_jupyter')
    assert_equal 'The Mode', css_select('label[for="batch_connect_session_context_mode"]').text
    assert_equal 'Jupyter Lab', css_select('label[for="batch_connect_session_context_mode_1"]').text
    assert_equal 'Jupyter Notebook', css_select('label[for="batch_connect_session_context_mode_0"]').text    
  end 

end