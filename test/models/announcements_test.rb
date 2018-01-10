require 'test_helper'

class AnnouncementsTest < ActiveSupport::TestCase
  test "should respond to each" do
    announcements = Announcements.new
    assert_respond_to announcements, :each
  end

  test "should return empty list if no valid path" do
    announcements = Announcements.all
    assert_equal 0, announcements.count
  end

  test "should not parse file that doesn't exist" do
    f = Tempfile.open(["announcement", ".md"])
    path = f.path
    f.close(true)

    announcements = Announcements.all(path)
    assert_equal 0, announcements.count
  end

  test "should parse single valid markdown file" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{Test announcement.}
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    announcement = announcements.first
    assert_equal :warning, announcement.type
    assert_equal "Test announcement.", announcement.msg
  end

  test "should not parse invalid markdown file" do
    f = Tempfile.open(["announcement", ".md"])
    f.write %{   \n \n \t    }
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 0, announcements.count
  end

  test "should parse a valid yaml file" do
    f = Tempfile.open(["announcement", ".yml"])
    f.write %{type: success\nmsg: <%= true ? "Test announcement." : "Fail!" %>}
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 1, announcements.count
    announcement = announcements.first
    assert_equal :success, announcement.type
    assert_equal "Test announcement.", announcement.msg
  end

  test "should not parse invalid yaml file" do
    f = Tempfile.open(["announcement", ".yml"])
    f.write %{type: success\nmsg: <%= true ? "null" : "Test announcement." %>}
    f.close

    announcements = Announcements.all(f.path)
    assert_equal 0, announcements.count
  end

  test "should parse a directory of files" do
    Dir.mktmpdir("announcements") do |dir|
      File.open("#{dir}/valid1.md", "w") do |f|
        f.write %{File 1}
      end
      File.open("#{dir}/valid2.yml", "w") do |f|
        f.write %{msg: "File 2"}
      end
      File.open("#{dir}/invalid1.yml", "w") do |f|
        f.write %{type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>"}
      end

      announcements = Announcements.all(dir)
      assert_equal 2, announcements.count
    end
  end

  test "should parse a list of valid and invalid files" do
    f1 = Tempfile.open(["valid", ".md"])
    f1.write %{File 1}
    f1.close
    f2 = Tempfile.open(["valid", ".yml"])
    f2.write %{msg: "File 2"}
    f2.close
    f3 = Tempfile.open(["invalid", ".yml"])
    f3.write %{type: danger\nmsg: "<%= true ? "  \n \t " : "Stuff" %>"}
    f3.close
    f4 = Tempfile.open(["does_not_exist", ".md"])
    f4_path = f4.path
    f4.close(true)

    announcements = Announcements.all([f1.path, f2.path, f3.path, f4_path])
    assert_equal 2, announcements.count
  end
end
