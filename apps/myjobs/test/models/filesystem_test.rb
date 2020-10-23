require 'test_helper'

class FilesystemTest < ActiveSupport::TestCase
  test "copy_dir copies directories excluding .git .svn and files in gitignore" do
    Dir.mktmpdir do |dir|
      tmp = Pathname.new(dir).join('t')
      tmp2 = Pathname.new(dir).join('t2')

      Filesystem.new.copy_dir Rails.root.join('example_templates', 'default'), tmp

      assert_equal 2, tmp.children.count, "job script and manifest should have been copied"

      tmp.join('.gitignore').write('manifest.yml')
      tmp.join('.git').mkpath
      tmp.join('.svn').mkpath

      Filesystem.new.copy_dir tmp, tmp2

      assert_equal 1, tmp2.children.count, "only job template should exist cause the manifest.yml should have been ignored"
    end
  end

  test "copy_dir doesn't allow command injection" do
    o,s = Filesystem.new.copy_dir("/dev/null';echo INJECTED;'", '/dev/null')
    assert_equal 0, o.split("\n").grep(/^INJECTED$/).count, "expected not to find INJECTED in output: #{o}"
  end
end
