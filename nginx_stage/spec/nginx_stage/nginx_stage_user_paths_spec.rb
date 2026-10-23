# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage do
  let(:user) { 'deleted_user' }
  let(:directory) { Dir.mktmpdir('cleanup.paths-') }

  before do
    allow(described_class).to receive(:pun_pid_path) do |user:|
      File.join(directory, 'run', user.to_s, "#{user}#{suffix}.pid")
    end
    allow(described_class).to receive(:pun_config_path) do |user:|
      File.join(directory, user.to_s, "#{user}#{suffix}.conf")
    end
    allow(described_class).to receive(:pun_secret_key_base_path) do |user:|
      File.join(directory, 'secrets', "#{user}.secret")
    end
    allow(NginxStage::User).to receive(:new).with(user).and_raise(ArgumentError)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  ['', '2', '10'].each do |ending|
    context "with repeated user fields followed by #{ending.inspect}" do
      let(:suffix) { ending }

      it 'finds the same user and escapes literal directory punctuation' do
        path = described_class.pun_config_path(user: user)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, '12345')
        expect(described_class.inactive_users).to eq([user])
      end

      it 'uses the same complete path matching for active-user discovery' do
        path = described_class.pun_pid_path(user: user)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, '12345')
        account = instance_double(NginxStage::User)
        allow(NginxStage::User).to receive(:new).with(user).and_return(account)
        expect(described_class.active_users).to eq([account])
      end

      it 'ignores a PID whose repeated username fields disagree' do
        FileUtils.mkdir_p(File.join(directory, 'run', user))
        File.write(File.join(directory, 'run', user, "different#{suffix}.pid"), '12345')
        expect(NginxStage::User).not_to receive(:new)
        expect(described_class.active_users).to eq([])
      end

      it 'rejects disagreement between repeated user fields' do
        FileUtils.mkdir_p(File.join(directory, user))
        File.write(File.join(directory, user, "different#{suffix}.conf"), '12345')
        expect(described_class.inactive_users).to eq([])
      end
    end
  end
end
