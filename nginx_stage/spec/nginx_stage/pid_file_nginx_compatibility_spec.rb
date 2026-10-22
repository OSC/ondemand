# frozen_string_literal: true

require 'spec_helper'
require 'nginx_stage'
require 'tmpdir'

RSpec.describe NginxStage::PidFile do
  let(:directory) { Dir.mktmpdir('pid-file-nginx-compatibility') }
  let(:pid_path) { File.join(directory, 'passenger.pid') }

  after do
    FileUtils.remove_entry(directory)
  end

  # Model nginx's fixed-size read and decimal conversion for these in-range
  # records, independently of the Ruby limit. No nginx executable is needed.
  # https://github.com/nginx/nginx/blob/master/src/core/ngx_cycle.c
  def nginx_target(contents)
    prefix = contents.b.byteslice(0, 22).sub(/[\r\n]+\z/, '')
    Integer(prefix, 10) if /\A[0-9]+\z/.match?(prefix)
  end

  {
    '1'                    => 1,
    "12345\n"              => 12_345,
    "000012345\r\n"        => 12_345,
    "2147483647\r\n"       => 2_147_483_647,
    "#{'0' * 21}1"         => 1,
    "#{'0' * 17}12345"     => 12_345,
    "#{'0' * 15}12345\r\n" => 12_345
  }.each do |contents, target|
    it "agrees with nginx for the complete record #{contents.inspect}" do
      File.write(pid_path, contents)

      expect(nginx_target(contents)).to eq(target)
      expect(described_class.new(pid_path).pid).to eq(target)
    end
  end

  {
    'a shortened target' => ["#{'0' * 18}12345", 1234],
    'PID 12'             => ["#{'0' * 20}12345", 12],
    'a process group'    => ["#{'0' * 22}12345", 0]
  }.each do |name, (contents, native_target)|
    it "rejects an overlong record that nginx truncates to #{name}" do
      File.write(pid_path, contents)
      expect(nginx_target(contents)).to eq(native_target)

      expect { described_class.new(pid_path) }.to raise_error(NginxStage::InvalidPidFile)
      expect(File.read(pid_path)).to eq(contents)
    end
  end

  ["12345#{"\n" * 18}", "#{' ' * 22}12345", "#{'0' * 100_000}12345"].each_with_index do |contents, index|
    it "rejects oversized file #{index} even when its full stripped token is a valid PID" do
      File.write(pid_path, contents)

      expect { described_class.new(pid_path) }.to raise_error(NginxStage::InvalidPidFile)
    end
  end

  it 'agrees with nginx across PID sizes, zero padding, and line-ending boundaries' do
    [1, 9, 10, 99, 100, 12_345, 2_147_483_647].each do |target|
      ['', "\n", "\r\n"].each do |ending|
        0.upto(22 - target.to_s.bytesize - ending.bytesize) do |padding|
          contents = ('0' * padding) + target.to_s + ending
          File.write(pid_path, contents)

          expect(described_class.new(pid_path).pid).to eq(nginx_target(contents))
          expect(nginx_target(contents)).to eq(target)
        end
      end
    end
  end
end
