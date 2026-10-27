# frozen_string_literal: true

require_relative 'e2e/e2e_helper'

# These helpers are top-level methods rather than a class.
RSpec.describe 'E2E helpers' do # rubocop:disable RSpec/DescribeClass
  let(:helper) { Object.new }

  around do |example|
    keys = ['OOD_E2E_BROWSER', 'OOD_E2E_EXPECTED_ARCH']
    original = keys.to_h { |key| [key, ENV[key]] }
    keys.each { |key| ENV.delete(key) }
    example.run
  ensure
    original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  describe 'browser selection' do
    it 'preserves the default headless Chrome configuration' do
      browser = instance_double(Watir::Browser)
      allow(Watir::Browser).to receive(:new)
        .with(:chrome, headless: true, options: { args: ['--disable-dev-shm-usage'] }).and_return(browser)

      expect(helper.send(:new_browser)).to be(browser)
    end

    it 'starts headless Firefox without Chrome-only options' do
      ENV['OOD_E2E_BROWSER'] = 'firefox'
      browser = instance_double(Watir::Browser)
      allow(Watir::Browser).to receive(:new).with(:firefox, headless: true).and_return(browser)

      expect(helper.send(:new_browser)).to be(browser)
    end

    it 'rejects an unsupported browser instead of silently choosing Chrome' do
      ENV['OOD_E2E_BROWSER'] = 'unsupported'
      expect(Watir::Browser).not_to receive(:new)

      expect { helper.send(:new_browser) }.to raise_error(ArgumentError, /Unsupported E2E browser/)
    end
  end

  describe 'target architecture verification' do
    it 'leaves local runs without an expected architecture unchanged' do
      expect(helper).not_to receive(:hosts)

      helper.send(:verify_host_architecture)
    end

    it 'accepts an empty optional architecture setting' do
      ENV['OOD_E2E_EXPECTED_ARCH'] = ''
      expect(helper).not_to receive(:hosts)

      helper.send(:verify_host_architecture)
    end

    ['x86_64', 'aarch64', 'ppc64le'].each do |architecture|
      it "checks the actual #{architecture} target rather than the runner CPU" do
        ENV['OOD_E2E_EXPECTED_ARCH'] = architecture
        allow(helper).to receive(:hosts).and_return(['target'])
        allow(helper).to receive(:on).with('target', 'uname -m').and_return(double(stdout: "#{architecture}\n"))

        expect { helper.send(:verify_host_architecture) }.not_to raise_error
      end
    end

    it 'fails when any target is the wrong architecture' do
      ENV['OOD_E2E_EXPECTED_ARCH'] = 'ppc64le'
      allow(helper).to receive(:hosts).and_return(['first', 'second'])
      allow(helper).to receive(:on).with('first', 'uname -m').and_return(double(stdout: "ppc64le\n"))
      allow(helper).to receive(:on).with('second', 'uname -m').and_return(double(stdout: "x86_64\n"))

      expect { helper.send(:verify_host_architecture) }
        .to raise_error(RuntimeError, 'second: expected architecture ppc64le, got x86_64')
    end
  end
end
