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

  # Test the files_button method
  test 'files_button should return a link to the project_file_path' do
    path = 'blargh/cat_videos/projects/path/to/file'
    expected_link = "<a target=\"_top\" class=\"link-light\" href=\"/files/fs/blargh/cat_videos/projects/path/to/file\">.../projects/path/to/file</a>"
    assert_equal(expected_link, files_button(path)) 
  end

  # Test the column_head_link method
  test 'column_head_link should return the correct link to the project_directory_path when column and sort_by are the same' do
    column = 'name'
    sort_by = 'name'
    path = Pathname.new('projects/path/to/file')
    project_id = '123'
    expected_link = "<a title=\"Show file directory\" class=\".*\" data-turbo-frame=\"project_directory\" href=\".*\">Name <i.*></i></a>"
    assert_match(/#{expected_link}/, column_head_link(column, sort_by, path, project_id))
  end

  test 'column_head_link should return the correct link to the project_directory_path when column and sort_by are different' do
    column = 'name'
    sort_by = 'size'
    path = Pathname.new('projects/path/to/file')
    project_id = '123'
    expected_link = "<a title=\"Show file directory\" class=\".*\" data-turbo-frame=\"project_directory\" href=\".*\">Name <i.*></i></a>"
    assert_match(/#{expected_link}/, column_head_link(column, sort_by, path, project_id))
  end

  # Test the header_text method
  test 'header_text should return the correct text when column and sort_by are the same' do
    column = 'name'
    sort_by = 'name'
    expected_text = "Name <i id=\"\" class=\"fas fa-sort-down fa-fw fa-md\" title=\"FontAwesome icon specified: sort-down\" aria-hidden=\"true\"></i>"
    assert_equal(expected_text, header_text(column, sort_by))
  end

  test 'header_text should return the correct text when column and sort_by are different' do
    column = 'name'
    sort_by = 'size'
    expected_text = "Name <i id=\"\" class=\"fas fa-sort fa-fw fa-md\" title=\"FontAwesome icon specified: sort\" aria-hidden=\"true\"></i>"
    assert_equal(expected_text, header_text(column, sort_by))
  end

  # Test the target_path method
  test 'target_path should return the correct path' do
    column = 'name'
    path = Pathname.new('projects/path/to/file')
    project_id = '123'
    expected_path = "/projects/123/directory?dir_path=projects%2Fpath%2Fto%2Ffile&sort_by=name"
    assert_equal(expected_path, target_path(column, path, project_id))
  end

  # Test the classes method
  test 'classes should return the correct classes when column and sort_by are the same' do
    column = 'name'
    sort_by = 'name'
    expected_classes = 'btn btn-xs btn-hover btn-primary'
    assert_equal(expected_classes, classes(column, sort_by))
  end

  test 'classes should return the correct classes when column and sort_by are different' do
    column = 'name'
    sort_by = 'size'
    expected_classes = 'btn btn-xs btn-hover btn-outline-primary'
    assert_equal(expected_classes, classes(column, sort_by))
  end
end
