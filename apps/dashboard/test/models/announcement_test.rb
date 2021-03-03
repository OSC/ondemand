require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  test 'should recognize CurrentUserSingleton#groups' do
    announcement = Announcement.new(
      "#{Rails.root}/test/fixtures/current_user/announcement/groups.yml")

    assert !announcement.msg.empty?
  end

  test 'should recognize CurrentUserSingleton#user_in_group?' do
    announcement = Announcement.new(
      "#{Rails.root}/test/fixtures/current_user/announcement/user_in_group.yml")

    assert !announcement.msg.empty?
  end
end 
