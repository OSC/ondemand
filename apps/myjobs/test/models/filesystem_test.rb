require 'test_helper'

class FilesystemTest < ActiveSupport::TestCase
  test "copy_dir doesn't allow command injection" do
    o,e,s = Filesystem.new.copy_dir("/dev/null';echo INJECTED;'", '/dev/null')
    refute_match /INJECTED/, o
  end
end
