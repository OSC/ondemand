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

  # let(:test_user) { "spec" }
  # let(:test_user_full_name) { "spec@domain.edu" }
  # let(:test_user_gid) { 1111 }

  # def stub_etc(username)
  #   etc_stub = {
  #     :gid => test_user_gid,
  #     :name => username
  #   }

  #   allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
  #   allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(nil)
  #   allow_any_instance_of(NginxStage::User).to receive(:get_groups).and_return([test_user])
  # end