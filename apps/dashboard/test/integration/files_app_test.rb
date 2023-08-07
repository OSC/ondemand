# frozen_string_literal: true

require 'test_helper'

class FilesAppTest < ActionDispatch::IntegrationTest
  test 'Files app displays terminal button when configuration is set to true' do
    Configuration.stubs(:files_enable_shell_button).returns(true)

    get '/files/fs/tmp'

    assert_select "div[id='shell-wrapper']", 1
  end

  test 'Files app does not displays terminal button when configuration is set to false' do
    Configuration.stubs(:files_enable_shell_button).returns(false)

    get '/files/fs/tmp'

    assert_select "div[id='shell-wrapper']", 0
  end

  test 'Files app shows error when tring to access remote files when remote files are disabled' do
    get files_url('s3', '/')
    assert_equal I18n.t('dashboard.files_remote_disabled'), flash[:alert]

    get files_url('s3', '/'), headers: { 'Accept': 'application/json' }
    json = JSON.parse(@response.body)
    assert_equal I18n.t('dashboard.files_remote_disabled'), json['error_message']
    assert_equal [], json['files']
  end
end
