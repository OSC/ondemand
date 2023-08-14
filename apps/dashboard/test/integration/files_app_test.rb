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

  test 'breadcrumbs shows remote prefix for remotes only' do
    get files_url(Rails.root.to_s)
    # Select breadcrumb items that are not buttons (change dir, copy path, etc.).
    local_breadcrumb = css_select('.breadcrumb-item')
                       .select { |el| (el > ('.btn')).empty? }
                       .map(&:inner_text).map(&:strip).join
    local_expected = "/#{Rails.root.each_filename.map(&:to_s).join(' /')} /"

    assert_equal local_expected, local_breadcrumb

    get files_url('local_remote', Rails.root.to_s)
    remote_breadcrumb = css_select('.breadcrumb-item')
                        .select { |el| (el > ('.btn')).empty? }
                        .map(&:inner_text).map(&:strip).join
    remote_expected = "local_remote: /#{Rails.root.each_filename.map(&:to_s).join(' /')} /"

    assert_equal remote_expected, remote_breadcrumb
  end
end
