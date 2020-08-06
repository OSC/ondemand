require 'spec_helper'
require 'nginx_stage'

describe NginxStage::PunConfigGenerator do
  let(:test_user){ "spec" }

  before(:each) {
    etc_stub = {
      :gid => 1000,
      :name => test_user
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow_any_instance_of(NginxStage::User).to receive(:get_groups).and_return([test_user])
  }

  it 'has the correct options' do
    expect(NginxStage::PunConfigGenerator.options.keys).to eq([:user, :skip_nginx, :app_init_url, :pre_hook_root_cmd])
  end

  it 'requires the user option' do
    expect { described_class.new }.to raise_error(NginxStage::MissingOption, "missing option: user")
  end


  describe 'pre_hook_root_cmd' do

    let(:generator){
      described_class.new({
        :user => test_user,
        :pre_hook_root_cmd => '/opt/pre_hook'
      })
    }

    let(:hook){
      generator.class.hooks[:exec_pre_hook]
    }

    it 'invokes the right root pre hook' do
      allow(Open3).to receive(:capture2e).with({}, '/opt/pre_hook', '--user', test_user)
      generator.instance_eval(&hook)
    end

    it 'correctly reads stdin when given good data' do
      env = {
        "FOO" => "BAR",
        "OIDC_ACCESS_TOKEN" => "TOKEN_BLAH_BLAH",
      }

      io = StringIO.new
      io.puts "FOO=BAR"
      io.puts "OIDC_ACCESS_TOKEN=TOKEN_BLAH_BLAH"
      io.rewind
      STDIN = io

      allow(Open3).to receive(:capture2e).with(env, '/opt/pre_hook', '--user', test_user)
      generator.instance_eval(&hook)
    end

    it 'disregards bad stdin input' do
      io = StringIO.new
      io.puts "as;dnf2354noasdfnaabn55243-aoasdf\n\n\n\n\n\nasf2n35235badsfnbasdf\n\r\n"
      io.rewind
      STDIN = io

      allow(Open3).to receive(:capture2e).with({}, '/opt/pre_hook', '--user', test_user)
      generator.instance_eval(&hook)
    end

    it 'eats any errors thrown from the underlying script' do
      allow(Open3).to receive(:capture2e).with({}, '/opt/pre_hook', '--user', test_user).and_raise(StandardError)
      generator.instance_eval(&hook)
    end
  end
end