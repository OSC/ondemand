# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::Generator do
  let(:user) { 'spec' }
  let(:directory) { Dir.mktmpdir('pun-start-result') }
  let(:config_path) { File.join(directory, 'pun.conf') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }
  let(:socket_path) { File.join(directory, 'passenger.sock') }
  let(:status) { instance_double(Process::Status, success?: true) }
  let(:nginx_output) { 'nginx: [emerg] bind() failed: address already in use' }

  before do
    passwd = Struct.new(:gid, :name, :uid, :shell).new(1000, user, 1000, '/bin/bash')
    group = Struct.new(:gid, :name).new(1000, user)
    allow(Etc).to receive(:getpwnam).with(user).and_return(passwd)
    allow(Etc).to receive(:getgrgid).with(1000).and_return(group)
    allow(NginxStage).to receive_messages(
      nginx_bin: '/usr/sbin/nginx', pun_config_path: config_path,
      pun_pid_path: pid_path, pun_socket_path: socket_path
    )
    allow(NginxStage).to receive(:nginx_args).with(user: generator.user).and_return(['-c', config_path])
    allow(NginxStage).to receive(:clean_nginx_env).with(user: generator.user)
  end

  after do
    FileUtils.remove_entry(directory)
  end

  {
    NginxStage::PunConfigGenerator    => {},
    NginxStage::AppConfigGenerator    => { sub_request: '/sys/dashboard' },
    NginxStage::NginxProcessGenerator => {}
  }.each do |generator_class, options|
    context "when starting through #{generator_class}" do
      let(:generator) { generator_class.new({ user: user }.merge(options)) }

      before do
        # Isolate reporting from filesystem staging, retaining the real output
        # hooks so returning instead of exiting cannot silently pass this test.
        reporting_hooks = generator_class.hooks.slice(
          :exec_nginx, :output_pun_config_path, :output_app_config_path, :output_nginx_cmd
        )
        allow(generator_class).to receive(:hooks).and_return(reporting_hooks)
      end

      it 'exits zero without emitting captured nginx output or generated paths' do
        expect(Open3).to receive(:capture2e)
          .with(['/usr/sbin/nginx', '(spec)'], '-c', config_path).once.and_return([nginx_output, status])

        expect do
          expect { generator.invoke }
            .to raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
        end.to output('').to_stdout.and output('').to_stderr
      end

      context 'when nginx fails' do
        let(:status) { instance_double(Process::Status, success?: false) }

        it 'exits one and reports the nginx error on stderr only' do
          expect(Open3).to receive(:capture2e)
            .with(['/usr/sbin/nginx', '(spec)'], '-c', config_path).once.and_return([nginx_output, status])

          expect do
            expect { generator.invoke }
              .to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
          end.to output('').to_stdout.and output("#{nginx_output}\n").to_stderr
        end
      end
    end
  end
end
