# frozen_string_literal: true

require 'test_helper'

class AnnouncementsTest < ActiveSupport::TestCase
  test 'should respond to each' do
    announcements = Announcements.new
    assert_respond_to announcements, :each
  end

  test 'should return empty list if no valid path' do
    announcements = Announcements.all
    assert_equal 0, announcements.count
  end

  test "should not create announcements for a file that doesn't exist" do
    f = Tempfile.open(['announcement', '.md'])
    path = f.path
    f.close(true)

    announcements = Announcements.all(path)
    assert_equal 0, announcements.count
    assert_equal 0, announcements.select(&:valid?).count
  end

  test 'should create valid announcement for markdown file' do
    f = Tempfile.open(['announcement', '.md'])
    f.write %(Test announcement.)
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 1, announcements.select(&:valid?).count
    announcement = announcements.first
    assert_equal :warning, announcement.type
    assert_equal 'Test announcement.', announcement.msg
  end

  test 'should create invalid announcement for markdown file w/ blank msg' do
    f = Tempfile.open(['announcement', '.md'])
    f.write %(   \n \n \t    )
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 0, announcements.select(&:valid?).count
  end

  test 'should create valid announcement a valid yaml file' do
    f = Tempfile.open(['announcement', '.yml'])
    f.write %(type: success\nmsg: <%= true ? "Test announcement." : "Fail!" %>)
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 1, announcements.select(&:valid?).count
    announcement = announcements.first
    assert_equal :success, announcement.type
    assert_equal 'Test announcement.', announcement.msg
  end

  test 'should create invalid announcement for yaml file w/ blank msg' do
    f = Tempfile.open(['announcement', '.yml'])
    f.write %(type: success\nmsg: <%= true ? "null" : "Test announcement." %>)
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 0, announcements.select(&:valid?).count
  end

  test 'does not crash when there are syntax errors' do
    f = Tempfile.open(['announcement', '.yml'])
    f.write '<%- end %>'
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 0, announcements.select(&:valid?).count
  end

  test 'should create announcement for syntax error' do
    f = Tempfile.open(['announcement', '.yml'])
    f.write('<%- end %>')
    f.close

    Rails.logger.expects(:warn).with(regexp_matches(/Syntax error in announcement file/))
    announcement = Announcements.all(f.path).first
    assert_equal(:warning, announcement.type)
  end

  test 'should create invalid announcement for invalid yaml file' do
    f = Tempfile.open(['announcement', '.yml'])
    f.write %(INVALID: YAML\nINVALID YAML)
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    assert_equal 0, announcements.select(&:valid?).count
  end

  test 'should create multiple announcements for a directory of files' do
    Dir.mktmpdir('announcements') do |dir|
      File.open("#{dir}/valid1.md", 'w') do |f|
        f.write %(File 1)
      end
      File.open("#{dir}/valid2.yml", 'w') do |f|
        f.write %(msg: "File 2")
      end
      File.open("#{dir}/invalid1.yml", 'w') do |f|
        f.write %(type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>")
      end
      File.open("#{dir}/invalid2.yml", 'w') do |f|
        f.write %(INVALID: YAML\nINVALID YAML)
      end
      File.open("#{dir}/invalid3.yml", 'w') do |f|
        f.write %(type: danger\nmsg: "<%= invalid ruby code %>")
      end

      announcements = Announcements.all(dir)
      assert_equal 5, announcements.count
      assert_equal 2, announcements.select(&:valid?).count
    end
  end

  test 'should create multiple announcements for a list of valid and invalid files' do
    f1 = Tempfile.open(['valid', '.md'])
    f1.write %(File 1)
    f1.close
    f2 = Tempfile.open(['valid', '.yml'])
    f2.write %(msg: "File 2")
    f2.close
    f3 = Tempfile.open(['invalid', '.yml'])
    f3.write %(type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>")
    f3.close
    f4 = Tempfile.open(['does_not_exist', '.md'])
    f4_path = f4.path
    f4.close(true)
    f5 = Tempfile.open(['invalid', '.yml'])
    f5.write %(INVALID: YAML\nINVALID YAML)
    f5.close
    f6 = Dir.mktmpdir('more_announcements')
    f7 = '~nonexistant_user/invalid/path.md'
    File.open("#{f6}/valid1.md", 'w') do |f|
      f.write %(File 1)
    end
    File.open("#{f6}/valid2.yml", 'w') do |f|
      f.write %(msg: "File 2")
    end
    File.open("#{f6}/invalid1.yml", 'w') do |f|
      f.write %(type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>")
    end
    File.open("#{f6}/invalid2.yml", 'w') do |f|
      f.write %(INVALID: YAML\nINVALID YAML)
    end
    File.open("#{f6}/invalid3.yml", 'w') do |f|
      f.write %(type: danger\nmsg: "<%= invalid ruby code %>")
    end
    Dir.mkdir("#{f6}/invalid4.yml")

    announcements = Announcements.all([f1.path, f2.path, f3.path, f4_path, f5.path, f6, f7])
    # could have been 12, but 2 were dropped because they don't exist.
    assert_equal 10, announcements.count
    assert_equal 4, announcements.select(&:valid?).count
  end
end
