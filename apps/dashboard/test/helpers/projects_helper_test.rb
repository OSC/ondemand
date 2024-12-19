require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ProjectsHelper

  # Test the render_readme method
  test 'render_readme should render markdown' do
    readme_location = 'test/fixtures/files/README.md'
    assert_match(/<h1>Test markdown README<\/h1>/, render_readme(readme_location))
  end

  test 'render_readme should render text' do
    readme_location = 'test/fixtures/files/README.txt'
    assert_match(/Test text README/, render_readme(readme_location))
  end

  # Test the job_details_buttons method
  test 'job_details_buttons should render correctly when status is "queued"' do
    expected_buttons = '<form class=\"button_to\" method=\"post\" action=\"\/projects\/456\/jobs\/test_cluster\/123\/stop\"><button data-confirm=\"Are you sure\?\" class=\"btn btn-danger\" type=\"submit\">Stop<.button><.form>'
    status = 'queued'
    job = HpcJob.new(id: '123', status: 'queued', cluster: 'test_cluster')
    cluster = 'test_cluster'
    project = Project.new(id: '456')
    stubs(:button_category).returns('queued') 
    assert_match(/#{expected_buttons}/, job_details_buttons(status, job, project))
  end
  
  test 'job_details_buttons should render correctly when status is "running"' do
    expected_buttons = '<form class=\"button_to\" method=\"post\" action=\"\/projects\/456\/jobs\/test_cluster\/123\/stop\"><button data-confirm=\"Are you sure\?\" class=\"btn btn-danger\" type=\"submit\">Stop<.button><.form>'
    status = 'running'
    job = HpcJob.new(id: '123', status: 'running', cluster: 'test_cluster')
    cluster = 'test_cluster'
    project = Project.new(id: '456')
    stubs(:button_category).returns('running') 
    assert_match(/#{expected_buttons}/, job_details_buttons(status, job, project))
  end
  
  test 'job_details_buttons should render correctly when status is "completed"' do
    expected_buttons = '<form class=\"button_to\" method=\"post\" action=\"\/projects\/456\/jobs\/test_cluster\/123\"><input type=\"hidden\" name=\"_method\" value=\"delete\" autocomplete=\"off\" /><button data-confirm=\"Are you sure\?\" class=\"btn btn-danger\" type=\"submit\">Delete<\/button><\/form>'
    status = 'completed'
    job = HpcJob.new(id: '123', status: 'completed', cluster: 'test_cluster')
    cluster = 'test_cluster'
    project = Project.new(id: '456')
    stubs(:button_category).returns('completed') 
    assert_match(/#{expected_buttons}/, job_details_buttons(status, job, project))
  end

  # Test the button_category method
  test 'button_category should return "held" when status is "queued_held"' do
    assert_equal('held', button_category('queued_held'))
  end

  test 'button_category should return "held" when status is "suspended"' do
    assert_equal('held', button_category('suspended'))
  end

  test 'button_category should return the status when status is not "queued_held" or "suspended"' do
    ['queued', 'running', 'completed'].each do |status|
      assert_equal(status, button_category(status))
    end
  end
end
