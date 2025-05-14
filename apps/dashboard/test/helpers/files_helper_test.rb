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
    expected_link = "<a target=\"_top\" class=\"link-light\" href=\"/files/fs/blargh/cat_videos/projects/path/to/file\">Open in files app</a>"
    assert_equal(expected_link, files_button(path)) 
  end
end