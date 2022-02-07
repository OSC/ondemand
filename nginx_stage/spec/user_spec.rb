require 'nginx_stage'
require 'spec_helper'

describe NginxStage::User do

  let(:test_user) { "spec" }
  let(:test_user_full_name) { "spec@domain.edu" }
  let(:test_user_gid) { 1111 }

  def stub_etc(username)
    etc_stub = {
      :gid => test_user_gid,
      :name => username
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(nil)
    allow_any_instance_of(NginxStage::User).to receive(:get_groups).and_return([test_user])
  end

  describe 'initialization' do

    it 'initializes correctly' do
      stub_etc(test_user)

      u = described_class.new(test_user)
      expect(u.name).to equal(test_user)
    end

    it 'raises an error when etc is different from username' do
      stub_etc(test_user_full_name)

      msg = <<~HEREDOC
        Username 'spec' is being mapped to 'spec@domain.edu' in SSSD and they don't match.
        Users with domain names cannot be mapped correctly. If 'spec@domain.edu' still has the
        domain in it you'll need to set SSSD's full_name_format to '%1$s'.
      
        See https://github.com/OSC/ondemand/issues/1759 for more details.
      HEREDOC
      expect { described_class.new(test_user) }.to raise_error(StandardError, msg)
    end
  end
end