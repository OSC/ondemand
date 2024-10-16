# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

describe NginxStage::PunConfigGenerator do
  let(:test_user) { 'spec' }
  let(:test_user_gid) { 1000 }

  before do
    etc_stub = {
      :gid  => test_user_gid,
      :name => test_user
    }

    allow(Etc).to receive(:getpwnam).with(test_user).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow(Etc).to receive(:getgrgid).with(test_user_gid).and_return(Struct.new(*etc_stub.keys).new(*etc_stub.values))
    allow_any_instance_of(NginxStage::User).to receive(:get_groups).and_return([test_user])
  end

  it 'has the correct options' do
    expect(described_class.options.keys).to eq([:user, :skip_nginx, :app_init_url, :pre_hook_root_cmd])
  end

  it 'requires the user option' do
    expect { described_class.new }.to raise_error(NginxStage::MissingOption, 'missing option: user')
  end

  describe 'pre_hook_root_cmd' do
    let(:generator)  do
      described_class.new({
                            :user              => test_user,
                            :pre_hook_root_cmd => '/opt/pre_hook'
                          })
    end

    let(:hook) do
      generator.class.hooks[:exec_pre_hook]
    end

    it 'invokes the right root pre hook' do
      allow(Open3).to receive(:capture3).with('/opt/pre_hook', '--user', test_user)
      generator.instance_eval(&hook)
    end

    it 'logs exceptions from underlying script' do
      allow(Open3).to receive(:capture3).with('/opt/pre_hook', '--user',
                                              test_user).and_raise(StandardError.new('this is a test'))
      allow_any_instance_of(Syslog::Logger).to receive(:error).with("/opt/pre_hook threw exception 'this is a test' for spec")
      generator.instance_eval(&hook)
    end

    it 'logs non-zero exits from underlying script' do
      allow(Open3).to receive(:capture3)
        .with('/opt/pre_hook', '--user', test_user)
        .and_return(['', 'this is the test stderr message', double(:success? => false, :exitstatus => 3)])

      allow_any_instance_of(Syslog::Logger).to receive(:error)
        .with("/opt/pre_hook exited with 3 for user spec. stderr was 'this is the test stderr message'")

      generator.instance_eval(&hook)
    end
  end
end
