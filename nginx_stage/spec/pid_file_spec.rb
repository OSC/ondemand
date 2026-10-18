# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::PidFile do
  {
    "1234\n" => 1234,
    " \t001234\n" => 1234,
    '1' => 1
  }.each do |contents, expected|
    it "reads the complete positive decimal PID #{contents.inspect}" do
      Dir.mktmpdir('pid-file-spec') do |dir|
        path = File.join(dir, 'passenger.pid')
        File.write(path, contents)
        expect(described_class.new(path).pid).to eq(expected)
      end
    end
  end

  ['', " \n", '0', '0000', '-1', '-12', '+123', '12abc', '12 34', "12\n34", '0x10', '1_000'].each do |contents|
    it "rejects the unsafe PID contents #{contents.inspect}" do
      Dir.mktmpdir('pid-file-spec') do |dir|
        path = File.join(dir, 'passenger.pid')
        File.write(path, contents)
        expect { described_class.new(path) }.to raise_error(NginxStage::InvalidPidFile)
      end
    end
  end
end
