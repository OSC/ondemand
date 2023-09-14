# frozen_string_literal: true

require 'test_helper'

class CurrentUserTest < ActiveSupport::TestCase
  test 'aliases from Etc work' do
    pwuid = Etc.getpwuid
    assert_equal pwuid.gid, CurrentUser.gid
    assert_equal pwuid.uid, CurrentUser.uid
    assert_equal pwuid.dir, CurrentUser.dir
    assert_equal pwuid.name, CurrentUser.name
    assert_equal pwuid.gecos, CurrentUser.gecos
    assert_equal pwuid.shell, CurrentUser.shell
  end

  test 'primary group is correct' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.gid
    assert_equal Etc.getgrgid(gid), CurrentUser.primary_group
  end

  test 'primary group name is correct' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.gid
    assert_equal Etc.getgrgid(gid).name, CurrentUser.primary_group_name
  end

  test 'primary group is first in groups' do
    gid = Etc.getpwuid.gid
    assert_equal gid, CurrentUser.groups.first.gid
  end

  test 'groups is the same as process.groups' do
    assert_equal Process.groups.to_set, CurrentUser.groups.map(&:gid).to_set
  end
end
