require 'test_helper'
require 'mocha/setup'

class AppRouterTest < ActiveSupport::TestCase
  test "DevRouter.apps" do
    dir = Pathname.new(File.realpath(Dir.mktmpdir))
    DevRouter.stubs(:base_path).returns(dir)
    %w(a b c .git).each {|d| dir.join(d).mkdir }
    FileUtils.touch dir.join("d.txt").to_s
    dir.join("c").chmod(0600)
    dir.join("d.txt").chmod(0700)

    assert_equal ["a", "b"].sort, DevRouter.apps(require_manifest: false).map(&:name).sort

    dir.rmtree()
  end
end
