# frozen_string_literal: true

require 'test_helper'

class NavTest < ActionDispatch::IntegrationTest
  test 'default for app to open in new window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(true)

    get '/'

    link = css_select('a[title="Job Composer"]').first

    assert link, 'Job Composer link not found on index page'
    assert_equal '_blank', link['target'], 'Job Composer link should be set to open in new window'
  end

  test 'default for app to open in same window' do
    SysRouter.stubs(:base_path).returns(Rails.root.parent)
    Configuration.stubs(:open_apps_in_new_window?).returns(false)

    get '/'

    link = css_select('a[title="Job Composer"]').first

    assert link, 'Job Composer link not found on index page'
    refute link['target'], 'Job Composer link should be set to open in same window'
  end
end
