# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

describe NginxStage::PidFile do
  let(:dir) { Dir.mktmpdir }
  let(:path) { File.join(dir, 'passenger.pid') }

  after { FileUtils.remove_entry(dir) }

  it 'accepts a positive decimal PID with whitespace and leading zeroes' do
    File.write(path, " 0123\n")

    expect(described_class.new(path).pid).to eq(123)
  end

  it 'accepts the maximum signed Linux pid_t value' do
    File.write(path, (2**31 - 1).to_s)

    expect(described_class.new(path).pid).to eq(2**31 - 1)
  end

  [
    '', "\n", '0', '-1', '+1', '12abc', '1 2', '2147483648',
    "\x00123", "123\x00\n"
  ].each do |contents|
    it "rejects invalid PID contents #{contents.inspect}" do
      File.write(path, contents)

      expect { described_class.new(path) }.to raise_error(NginxStage::InvalidPidFile)
    end
  end

  it 'accepts a valid PID file at the size limit' do
    File.write(path, '123' + ' ' * 19)

    expect(described_class.new(path).pid).to eq(123)
  end

  it 'rejects a valid PID file one byte over the size limit' do
    File.write(path, '123' + ' ' * 20)

    expect { described_class.new(path) }.to raise_error(NginxStage::InvalidPidFile)
  end

  it 'preserves the missing-file error' do
    expect { described_class.new(path) }.to raise_error(NginxStage::MissingPidFile)
  end
end
