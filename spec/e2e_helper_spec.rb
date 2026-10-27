# frozen_string_literal: true

require 'yaml'
require 'open3'
require 'tmpdir'
require_relative 'e2e/e2e_helper'

# These helpers are top-level methods rather than a class.
RSpec.describe 'E2E helpers' do # rubocop:disable RSpec/DescribeClass
  let(:helper) { Object.new }

  around do |example|
    keys = ['OOD_E2E_BROWSER', 'OOD_E2E_EXPECTED_ARCH', 'SE_GECKODRIVER']
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

    it 'exports a native Firefox driver and bypasses the locked x86 Selenium Manager' do
      workflow = YAML.load_file(File.join(__dir__, '../.github/workflows/tests.yml'))
      steps = workflow.fetch('jobs').fetch('e2e-tests').fetch('steps')
      script = steps.find { |step| step['name'] == 'Check browser and driver' }.fetch('run')

      Dir.mktmpdir('ood-firefox') do |dir|
        ['firefox', 'geckodriver'].each do |name|
          path = File.join(dir, name)
          File.write(path, "#!/bin/sh\nexit 0\n")
          File.chmod(0o755, path)
        end
        environment_file = File.join(dir, 'github_env')
        env = {
          'PATH'            => "#{dir}:#{ENV.fetch('PATH')}",
          'OOD_E2E_BROWSER' => 'firefox',
          'GITHUB_ENV'      => environment_file
        }
        _stdout, stderr, status = Open3.capture3(env, 'bash', '-e', '-c', script)
        expect(status).to be_success, stderr
        expect(File.read(environment_file)).to eq("SE_GECKODRIVER=#{dir}/geckodriver\n")

        ENV['SE_GECKODRIVER'] = File.read(environment_file).strip.delete_prefix('SE_GECKODRIVER=')
        service = Selenium::WebDriver::Firefox::Service.new
        driver = Selenium::WebDriver::Firefox::Driver.allocate
        expect(Selenium::WebDriver::SeleniumManager).not_to receive(:binary_paths)

        options = Selenium::WebDriver::Firefox::Options.new
        expect(driver.send(:process_options, options, service).fetch('browserName')).to eq('firefox')
        expect(service.executable_path).to eq(File.join(dir, 'geckodriver'))
      end
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

  describe 'architecture nodesets' do
    it 'uses a published ARM image for EL10' do
      path = File.join(__dir__, 'e2e', 'nodesets', 'el10-aarch64.yml')
      host = YAML.load_file(path).fetch('HOSTS').values.first

      expect(host.fetch('image')).to eq('arm64v8/almalinux:10')
    end

    ['el8', 'el9', 'el10', 'amzn2023', 'ubuntu-24.04', 'ubuntu-26.04', 'debian-12', 'debian-13'].each do |distribution|
      it "provides an ARM target for #{distribution}" do
        path = File.join(__dir__, 'e2e', 'nodesets', "#{distribution}-aarch64.yml")
        host = YAML.load_file(path).fetch('HOSTS').values.first

        expect(host.fetch('platform')).to match(/-(aarch64|arm64)\z/)
        expect(host.fetch('docker_port_bindings').fetch('8080/tcp').first.fetch('HostPort')).to eq('8080')
      end
    end

    ['el8', 'el9', 'el10'].each do |distribution|
      it "uses a PowerPC-only base image for #{distribution}" do
        path = File.join(__dir__, 'e2e', 'nodesets', "#{distribution}-ppc64le.yml")
        host = YAML.load_file(path).fetch('HOSTS').values.first

        expect(host.fetch('platform')).to end_with('-ppc64le')
        expect(host.fetch('image')).to eq("ppc64le/almalinux:#{distribution.delete_prefix('el')}")
      end
    end
  end
end
