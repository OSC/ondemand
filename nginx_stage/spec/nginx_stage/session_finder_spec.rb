# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

RSpec.describe NginxStage::SessionFinder do
  let(:finder) { Object.new.extend(described_class) }

  it 'counts Passenger apps only after a successful process listing' do
    status = instance_double(Process::Status, success?: true, exitstatus: 0)
    output = "CMD\nPassenger RubyApp: /a\nPassenger NodeApp: /b\nnginx: worker process\n"
    allow(Open3).to receive(:capture3).with('timeout', '10', 'ps', '-o', 'cmd', '-u', 'example')
                                      .and_return([output, '', status])
    expect(finder.session_count('example')).to eq(2)
  end

  it 'accepts a successful listing without Passenger apps as zero sessions' do
    status = instance_double(Process::Status, success?: true, exitstatus: 0)
    allow(Open3).to receive(:capture3).and_return(["CMD\nnginx: worker process\n", '', status])
    expect(finder.session_count('example')).to eq(0)
  end

  it 'propagates failure to execute the command instead of reporting zero' do
    allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT)
    expect { finder.session_count('example') }.to raise_error(Errno::ENOENT)
  end

  it 'accepts the procps empty-selection status only with a clean header-only result' do
    status = instance_double(Process::Status, success?: false, exitstatus: 1)
    allow(Open3).to receive(:capture3).and_return(["CMD\n", '', status])
    expect(finder.session_count('idle')).to eq(0)
  end

  [
    ["CMD\n", 'ps: cannot read process table'],
    ['', ''],
    ["CMD\nPassenger RubyApp: /partial\n", '']
  ].each do |output, error|
    it "rejects status 1 with inconclusive output #{[output, error].inspect}" do
      status = instance_double(Process::Status, success?: false, exitstatus: 1)
      allow(Open3).to receive(:capture3).and_return([output, error, status])
      expect { finder.session_count('example') }.to raise_error(NginxStage::Error, /ps failed/)
    end
  end
end
