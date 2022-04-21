require 'test_helper'

class CurrentUserTest < ActiveSupport::TestCase

  test "aliases from Etc work" do
    pwuid = Etc.getpwuid
    assert_equal pwuid.gid, CurrentUser.gid
    assert_equal pwuid.uid, CurrentUser.uid
    assert_equal pwuid.dir, CurrentUser.dir
    assert_equal pwuid.dir, CurrentUser.home
    assert_equal pwuid.name, CurrentUser.name
    assert_equal pwuid.gecos, CurrentUser.gecos
    assert_equal pwuid.shell, CurrentUser.shell
  end

  test "primary group is correct" do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.gid
    assert_equal Etc.getgrgid(gid).name, CurrentUser.primary_group
  end
end