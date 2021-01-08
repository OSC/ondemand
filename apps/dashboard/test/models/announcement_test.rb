require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  test 'should recognize ERBRenderHelper#groups' do
    announcement = Announcement.new(
      "#{Rails.root}/test/fixtures/erb/announcement/groups_helper.yml")
    
    assert !announcement.msg.empty?
  end

  test 'should recognize ERBRenderHelper#user_in_group?' do
    announcement = Announcement.new(
      "#{Rails.root}/test/fixtures/erb/announcement/user_in_group_helper.yml")
    
    assert !announcement.msg.empty?
  end
end 
