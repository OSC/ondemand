# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::SessionFinder do
  let(:finder) { Class.new { include NginxStage::SessionFinder }.new }

  def ps_result(out, err, exitstatus)
    status = instance_double(Process::Status, success?: exitstatus == 0, exitstatus: exitstatus)
    allow(Open3).to receive(:capture3).with('timeout', '10', 'ps', '-o', 'cmd', '-u', 'spec')
      .and_return([out, err, status])
  end

  it 'counts Passenger application processes' do
    ps_result("CMD\nPassenger RubyApp: /app\nnginx: worker process\nPassenger NodeApp: /other\n", '', 0)

    expect(finder.session_count('spec')).to eq(2)
  end

  it 'accepts an empty process selection from ps' do
    ps_result("CMD\n", '', 1)

    expect(finder.session_count('spec')).to eq(0)
  end

  [1, 124, 127, nil].each do |exitstatus|
    it "rejects ps failure #{exitstatus.inspect} instead of reporting zero sessions" do
      ps_result('', 'process listing failed', exitstatus)

      expect { finder.session_count('spec') }.to raise_error(NginxStage::Error, /unable to count sessions/)
    end
  end

  it 'rejects a timeout even when stderr is empty' do
    ps_result('', '', 124)

    expect { finder.session_count('spec') }.to raise_error(NginxStage::Error, /ps exit 124/)
  end

  it 'does not accept a partial process listing after a timeout' do
    ps_result("CMD\nPassenger RubyApp: /app\n", '', 124)

    expect { finder.session_count('spec') }.to raise_error(NginxStage::Error, /ps exit 124/)
  end
end

describe 'nginx_clean session counting' do
  let(:dir) { Dir.mktmpdir }
  let(:pid_path) { File.join(dir, 'passenger.pid') }

  before do
    File.write(pid_path, Process.pid.to_s)
    allow(NginxStage).to receive(:pun_pid_path).and_return(pid_path)
    allow(NginxStage).to receive(:pun_config_path).and_return(File.join(dir, 'spec.conf'))
    allow(NginxStage).to receive(:active_users).and_return(['spec'])
    allow(NginxStage).to receive(:inactive_users).and_return([])
    allow(NginxStage::SocketFile).to receive(:new).and_return(instance_double(NginxStage::SocketFile))
  end

  after { FileUtils.remove_entry(dir) }

  it 'bypasses session counting with --force' do
    generator = NginxStage::NginxCleanGenerator.new(force: true, skip_nginx: true)
    expect(generator).not_to receive(:session_count)

    expect { generator.invoke }.to output("spec\n").to_stdout.and output('').to_stderr
  end

  it 'leaves the PUN alone when session counting fails' do
    generator = NginxStage::NginxCleanGenerator.new
    allow(generator).to receive(:session_count).and_raise(NginxStage::Error, 'ps failed')
    expect(Open3).not_to receive(:capture2e)

    expect { generator.invoke }.to output("ps failed\n").to_stderr.and output('').to_stdout
    expect(File.exist?(pid_path)).to be(true)
  end
end
