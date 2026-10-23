# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'

RSpec.describe NginxStage::SessionFinder do
  let(:finder) { Object.new.extend(described_class) }

  it 'counts Passenger apps only after a successful process listing' do
    status = instance_double(Process::Status, success?: true)
    output = "CMD\nPassenger RubyApp: /a\nPassenger NodeApp: /b\nnginx: worker process\n"
    expect(Open3).to receive(:capture2).with('timeout', '10', 'ps', '-o', 'cmd', '-u', 'example')
                                       .and_return([output, status])
    expect(finder.session_count('example')).to eq(2)
  end

  it 'accepts a successful listing without Passenger apps as zero sessions' do
    status = instance_double(Process::Status, success?: true)
    allow(Open3).to receive(:capture2).and_return(["CMD\nnginx: worker process\n", status])
    expect(finder.session_count('example')).to eq(0)
  end

  it 'propagates failure to execute the command instead of reporting zero' do
    allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT)
    expect { finder.session_count('example') }.to raise_error(Errno::ENOENT)
  end
end
