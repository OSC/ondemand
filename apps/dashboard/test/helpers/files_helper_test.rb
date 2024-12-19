require 'test_helper'

class FilesHelperTest < ActionView::TestCase
  include FilesHelper

  # Test the path_segment_with_slash method
  test 'path_segment_with_slash should return the correct segment when counter is 0 and filesystem is fs' do
    filesystem = 'fs'
    segment = 'projects'
    counter = 0
    total = 5
    assert_equal(segment, path_segment_with_slash(filesystem, segment, counter, total))
  end

  test 'path_segment_with_slash should return the correct segment when counter is 0 and filesystem is not fs' do
    filesystem = 'LCD_filesystem'
    segment = 'projects'
    counter = 0
    total = 5
    assert_equal('LCD_filesystem: projects', path_segment_with_slash(filesystem, segment, counter, total))
end

  test 'path_segment_with_slash should return the correct segment when counter is not 0' do
    filesystem = 'fs'
    segment = 'projects'
    counter = 1
    total = 5
    assert_equal('projects /', path_segment_with_slash(filesystem, segment, counter, total))
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
    assert_match(/#{expected_link}/, column_head_link(column, sort_by, path))
  end

  test 'column_head_link should return the correct link to the project_directory_path when column and sort_by are different' do
    column = 'name'
    sort_by = 'size'
    path = Pathname.new('projects/path/to/file')
    project_id = '123'
    expected_link = "<a title=\"Show file directory\" class=\".*\" data-turbo-frame=\"project_directory\" href=\".*\">Name <i.*></i></a>"
    assert_match(/#{expected_link}/, column_head_link(column, sort_by, path))
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
    expected_path = "/frames/directory_frame?path=projects%2Fpath%2Fto%2Ffile&sort_by=name"
    assert_equal(expected_path, target_path(column, path))
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