# frozen_string_literal: true

require 'test_helper'

class LaunchersControllerTest < ActionController::TestCase
  test 'save_launcher_params allows properly named auto_environment_variable keys' do
    @controller.params = ActionController::Parameters.new({
      project_id: '1',
      id:         '1',
      launcher:   {
        cluster:                        'ascend',
        auto_environment_variable_PATH: '/usr/bin',
        auto_environment_variable_HOME: '/home/user'
      }
    })

    permitted = @controller.send(:save_launcher_params)
    assert_equal '/usr/bin',    permitted[:launcher]['auto_environment_variable_PATH']
    assert_equal '/home/user',  permitted[:launcher]['auto_environment_variable_HOME']
  end

  test 'save_launcher_params rejects bare auto_environment_variable key with no variable name' do
    @controller.params = ActionController::Parameters.new({
      project_id: '1',
      id:         '1',
      launcher:   {
        cluster:                   'ascend',
        auto_environment_variable: ''
      }
    })

    permitted = @controller.send(:save_launcher_params)
    assert_nil permitted[:launcher]['auto_environment_variable']
    assert_equal 'ascend', permitted[:launcher]['cluster']
  end
end
