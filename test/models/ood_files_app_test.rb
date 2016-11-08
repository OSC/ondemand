require 'test_helper'

class OodFilesAppTest < ActiveSupport::TestCase

  setup do
    @app = OodFilesApp.new
  end

  def p(str)
    Pathname.new(str)
  end


  test "basic template str" do
    assert_equal [], @app.paths_from_template(nil, basename_filter: nil)
    assert_equal [p("/fs/p1")], @app.paths_from_template("/fs/p1", basename_filter: nil)
    assert_equal [p("/fs/p1"), p("/fs/p2")], @app.paths_from_template("/fs/p1:/fs/p2", basename_filter: nil)
  end

  test "templating groups" do
    User.any_instance.stubs(:groups).returns(
      %w(PZS0562 PZS0530 hpcsoft wiag).map {|g| OpenStruct.new(name: g)}
    )

    assert_equal [p('/fs/PZS0562'), p('/fs/PZS0530'), p('/fs/hpcsoft'), p('/fs/wiag')],
      @app.paths_from_template("/fs/%{group}"), "supposed to expand into a path for each group the user is in"
  end

  test "filtering template paths" do
    User.any_instance.stubs(:groups).returns(
      %w(PZS0562 PZS0530 hpcsoft wiag).map {|g| OpenStruct.new(name: g)}
    )
    assert_equal [p('/fs/PZS0562'), p('/fs/PZS0530')],
      @app.paths_from_template("/fs/%{group}", basename_filter: '^P'), "supposed to filter paths by provided regex filter (if provided)"
  end
end
