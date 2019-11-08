require 'spec_helper'
require File.expand_path '../../lib/ood_portal_generator', __FILE__

describe OodPortalGenerator::Application do
  let(:argv) do
    %W()
  end

  before(:each) do
    stub_const('ARGV', argv)
  end

  it 'runs generate' do
    expect { described_class.start('generate') }.to output(/VirtualHost/).to_stdout
  end
end
