require 'test_helper'

class OodFilesAppTest < ActiveSupport::TestCase

  setup do
    @app = OodFilesApp.new
  end


  test "basic template str" do
    assert_equal [], @app.paths_from_templates(nil, nil)
    assert_equal [Pathname.new("/fs/p1")], @app.paths_from_templates("/fs/p1", nil)
    assert_equal [Pathname.new("/fs/p1"), Pathname.new("/fs/p2")], @app.paths_from_templates("/fs/p1:/fs/p2", nil)
  end
end
