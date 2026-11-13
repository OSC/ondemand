# frozen_string_literal: true

require 'test_helper'

# Announcement model basic tests
class AnnouncementTest < ActiveSupport::TestCase

  test 'default values' do
    target = Announcement.new({})

    assert_equal(:warning, target.type)
    assert_nil(target.msg)
    assert_nil(target.id)
    assert_equal(false, target.completed?)
    assert_equal(true, target.dismissible?)
    assert_equal(false, target.required?)
  end

  test 'default id for announcement file is msg sha1' do
    path = Rails.root.join('test/fixtures/config/announcements/announcement_id.yml').to_s
    target = Announcement.new(path)

    assert_equal('9b4ad10e7b43c149e08c1530db6810c7a6bbea13', target.id)
  end

  test 'can set values with hash' do
    target = Announcement.new(
      { type:        'info',
        msg:         'This is the message',
        id:          '12345',
        dismissible: true,
        required:    true }
    )

    assert_equal(:info, target.type)
    assert_equal('This is the message', target.msg)
    assert_equal('12345', target.id)
    assert_equal(false, target.completed?)
    assert_equal(true, target.dismissible?)
    assert_equal(true, target.required?)
  end

  test 'can set values with YAML file' do
    path = Rails.root.join('test/fixtures/config/announcements/announcement_yml.yml').to_s
    target = Announcement.new(path)

    assert_equal(:danger, target.type)
    assert_equal('This is yaml', target.msg)
    assert_equal('yml_id', target.id)
    assert_equal(false, target.completed?)
    assert_equal(true, target.dismissible?)
    assert_equal(true, target.required?)
  end

  test 'can set message with MD file' do
    path = Rails.root.join('test/fixtures/config/announcements/announcement_md.md').to_s
    target = Announcement.new(path)

    assert_equal(:warning, target.type)
    assert_equal('This is md', target.msg)
    assert_equal('77b8dd73d876bb58be9eae133fb8f5c614b95171', target.id)
    assert_equal(false, target.completed?)
    assert_equal(true, target.dismissible?)
    assert_equal(false, target.required?)
  end

  test 'required announcements are dismissible' do
    target = Announcement.new({ required: true })
    assert_equal(true, target.dismissible?)
    assert_equal(true, target.required?)
  end

  test 'required takes precedence over dismissible' do
    target = Announcement.new(
      { dismissible: false,
        required:    true }
    )
    assert_equal(true, target.dismissible?)
    assert_equal(true, target.required?)
  end

  test 'valid? should be false if msg is not present' do
    target = Announcement.new({id: '12345', dismissible: true, required: true})
    assert_equal(false, target.valid?)
  end

  test 'valid? should be true if msg is present' do
    target = Announcement.new({ msg: 'message value' })
    assert_equal(true, target.valid?)
  end

  test 'valid? should be true if required? is true and id and msg are present' do
    target = Announcement.new({ msg: 'message value', id: '12345', required: true })
    assert_equal(true, target.valid?)
  end

  test 'valid? should be true with or without a token' do
    target = Announcement.new({ msg: 'message value', token: 'sys/bc_desktop' })
    assert_equal(true, target.valid?)

    target = Announcement.new({ msg: 'message value' })
    assert_equal(true, target.valid?)
  end

  test 'completed? should be true if announcement is dismissible and id is stored in the user settings' do
    file = "#{Rails.root}/test/fixtures/file_output/user_settings/announcements.yml" if file.blank?
    Configuration.stubs(:user_settings_file).returns(file)
    target = Announcement.new({ id: 'completed_id', dismissible: false })
    assert_equal(false, target.completed?)

    target = Announcement.new({ id: 'completed_id', dismissible: true })
    assert_equal(true, target.completed?)
  end

  test 'global? is true when token is missing or empty' do
    assert_equal(true, Announcement.new({ msg: 'test' }).global?)
    assert_equal(true, Announcement.new({ msg: 'test', token: '' }).global?)
    assert_equal(true, Announcement.new({ msg: 'test', token: '   ' }).global?)
  end

  test 'global? is false when token is set' do
    target = Announcement.new({ msg: 'test', token: 'sys/app' })

    assert_equal(false, target.global?)
  end

  test 'token returns the configured token as a string' do
    target = Announcement.new({ msg: 'test', token: 'sys/app' })
    assert_equal('sys/app', target.token)

    target = Announcement.new({ msg: 'test', token: 123 })
    assert_equal('123', target.token)
  end

  test 'token is empty when missing or blank' do
    target = Announcement.new({ msg: 'test' })
    assert_equal('', target.token)

    target = Announcement.new({ msg: 'test', token: '' })
    assert_equal('', target.token)

    target = Announcement.new({ msg: 'test', token: '   ' })
    assert_equal('', target.token)
  end

  test 'applies_to? is true for global announcements on any request' do
    target = Announcement.new({ msg: 'test' })
    assert_equal(true, target.applies_to?('sys/bc_desktop'))
    assert_equal(true, target.applies_to?(nil))
    assert_equal(true, target.applies_to?(''))
  end

  test 'applies_to? is true for the targeted app and its sub-apps' do
    target = Announcement.new({ msg: 'test', token: 'sys/bc_desktop' })

    assert_equal(true, target.applies_to?('sys/bc_desktop'))
    assert_equal(true, target.applies_to?('sys/bc_desktop/owens'))
  end

  test 'applies_to? is false for other apps' do
    target = Announcement.new({ msg: 'test', token: 'sys/bc_desktop' })

    assert_equal(false, target.applies_to?('sys/bc_desktop_gpu'))
    assert_equal(false, target.applies_to?('sys/other_app'))
  end

  test 'applies_to? is false for app announcements when request_token is nil or empty' do
    target = Announcement.new({ msg: 'test', token: 'sys/bc_desktop' })

    assert_equal(false, target.applies_to?(nil))
    assert_equal(false, target.applies_to?(''))
  end

  test 'applies_to? supports glob tokens' do
    target = Announcement.new({ msg: 'test', token: 'sys/*' })

    assert_equal(true, target.applies_to?('sys/bc_desktop'))
    assert_equal(false, target.applies_to?('dev/my_app'))
  end

  test 'applies_to? is true for a sub-app announcement on its own page' do
    target = Announcement.new({ msg: 'test', token: 'sys/bc_desktop/owens' })

    assert_equal(true, target.applies_to?('sys/bc_desktop/owens'))
  end

  test 'applies_to? does not match a sub-app announcement on its base app' do
    target = Announcement.new({ msg: 'test', token: 'sys/bc_desktop/owens' })

    assert_equal(false, target.applies_to?('sys/bc_desktop'))
  end

end
