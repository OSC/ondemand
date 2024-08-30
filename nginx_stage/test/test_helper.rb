require 'ostruct'
require 'mocha/minitest'
require 'nginx_stage'

module TestHelper

  def user(username = 'test')
    OpenStruct.new(:name => username, :gid => 1111)
  end

  def stub_user(username = test)
    Etc.stubs(:getpwnam).returns(user(username))
    Etc.stubs(:getgrgid).returns(nil)
    NginxStage::User.any_instance.stubs(:get_groups).returns(['test'])
  end
end
