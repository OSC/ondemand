# frozen_string_literal: true

require 'minitest/autorun'
require 'yaml'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'

# Check the workflow's contracts with RPM packaging, AppArmor and Selenium.
class CiDebugConfigurationTest < Minitest::Test
  ROOT = File.expand_path('../../..', __dir__)
  WORKFLOW = YAML.load_file(File.join(ROOT, '.github/workflows/ci-debug.yml')).fetch('jobs')

  def test_package_checkout_name_matches_rpm_source_name
    checkout = WORKFLOW.fetch('package').fetch('steps').find do |step|
      step.dig('with', 'repository') == 'OSC/ondemand'
    end
    spec = File.read(File.join(ROOT, 'packaging/rpm/ondemand.spec'))
    package = spec.match(/^%global package_name (\S+)$/)[1]
    assert_equal package, File.basename(checkout.fetch('with').fetch('path')),
                 'ood_packaging derives its tarball name from the checkout basename'
    directories = WORKFLOW.fetch('package').fetch('steps').filter_map { |step| step['working-directory'] }
    assert_equal [checkout.fetch('with').fetch('path')], directories.uniq
  end

  def sandbox_step
    WORKFLOW.fetch('browser').fetch('steps').find { |step| step['name'] == 'Allow downloaded Chrome sandbox' }
  end

  def with_sandbox_command(filename = 'chrome')
    Dir.mktmpdir('ci-debug-config-') do |directory|
      chrome = File.join(directory, filename)
      File.write(chrome, "#!/bin/sh\nexit 0\n")
      File.chmod(0o755, chrome)
      sudo = File.join(directory, 'sudo')
      File.write(sudo, "#!/bin/sh\n[ \"$*\" = '-n apparmor_parser --replace' ] || exit 98\ncat\n")
      File.chmod(0o755, sudo)
      env = { 'CI_DEBUG_CHROME' => chrome, 'PATH' => "#{directory}:#{ENV.fetch('PATH')}" }
      yield env, File.realpath(chrome)
    end
  end

  def test_downloaded_browser_has_a_path_scoped_user_namespace_policy
    refute_nil sandbox_step, 'Downloaded Chrome needs a sandbox policy before any test starts'
    with_sandbox_command do |env, chrome|
      output, error, status = Open3.capture3(env, 'bash', '-e', '-c', sandbox_step.fetch('run'))
      assert status.success?, error
      assert_includes output, "profile ci-debug-chrome \"#{chrome}\" flags=(unconfined)"
      assert_includes output, "  userns,\n"
      refute_includes output, '*'
    end
  end

  def test_sandbox_policy_rejects_paths_with_apparmor_metacharacters
    refute_nil sandbox_step, 'Downloaded Chrome needs a sandbox policy before any test starts'
    with_sandbox_command('chrome[glob]') do |env, _chrome|
      output, _error, status = Open3.capture3(env, 'bash', '-e', '-c', sandbox_step.fetch('run'))
      assert_equal 2, status.exitstatus
      assert_empty output
    end
  end

  def with_browser_service
    Dir.mktmpdir('ci-debug-browser-') do |directory|
      File.write(File.join(directory, 'application_system_test_case.rb'), <<~RUBY)
        class ApplicationSystemTestCase
          DOWNLOAD_DIRECTORY = #{directory.dump}
          def self.driven_by(*, **options)
            const_set(:SERVICE, options.fetch(:options).fetch(:service))
            yield Selenium::WebDriver::Chrome::Options.new
          end
        end
      RUBY
      env = { 'CI_DEBUG_DIR' => directory, 'CI_DEBUG_CHROME' => '/bin/true',
              'CI_DEBUG_CHROMEDRIVER' => '/bin/true' }
      helper = File.join(ROOT, 'script/ci-debug/browser.rb')
      yield directory, env, helper
    end
  end

  def test_selenium_keeps_both_logs_and_appends_across_service_starts
    with_browser_service do |directory, env, helper|
      script = <<~RUBY
        require #{helper.dump}
        service = ApplicationSystemTestCase::SERVICE
        io = service.log
        abort 'Selenium rewrites String logs into --log-path' unless io.is_a?(IO)
        abort 'Missing --append-log' unless service.args.include?('--append-log')
        abort 'Duplicate --log-path' unless service.args.grep(/^--log-path=/).size == 1
        2.times do
          child = Selenium::WebDriver::ChildProcess.build(#{RbConfig.ruby.dump}, '-e', 'puts "child output"')
          child.io = io
          child.start
          child.wait
        end
      RUBY
      _output, error, status = Open3.capture3(env, RbConfig.ruby, "-I#{directory}", '-e', script)
      assert status.success?, error
      assert_equal "child output\nchild output\n", File.read(File.join(directory, 'chromedriver-stderr.log'))
    end
  end
end
