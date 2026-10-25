# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'rbconfig'
require_relative '../events'

# Exercise real command exit statuses and Minitest failure collection.
class CiDiagnosticsTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  # Intentionally failing examples are run manually, not through discovery.
  class Example < Minitest::Test
    prepend CiDebugEvents
    attr_accessor :body_error, :teardown_error

    def exercise
      raise body_error if body_error
    end

    def before_teardown
      raise teardown_error if teardown_error
    end
  end

  def with_runner(collector_status: 0)
    Dir.mktmpdir('ci-debug-test-') do |directory|
      FileUtils.cp(File.join(ROOT, 'run.sh'), directory)
      File.write(File.join(directory, 'collect.sh'), "exit #{collector_status}\n")
      yield directory, File.join(directory, 'artifacts')
    end
  end

  def command(directory, artifacts, *arguments)
    Open3.capture3({ 'CI_DEBUG_DIR' => artifacts }, 'bash', File.join(directory, 'run.sh'), *arguments)
  end

  def test_success_preserves_stdout_and_stderr
    with_runner do |directory, artifacts|
      output, _error, status = command(directory, artifacts, 'pass', RbConfig.ruby,
                                       '-e', '$stdout.sync = true; puts "stdout"; warn "stderr"')
      assert status.success?
      assert_includes output, 'stdout'
      assert_includes output, 'stderr'
      assert_equal output, File.read(File.join(artifacts, 'pass-output.log'))
      assert_equal "0\n", File.read(File.join(artifacts, 'pass-status.txt'))
    end
  end

  def test_failure_status_survives_successful_tee
    with_runner do |directory, artifacts|
      _output, _error, status = command(directory, artifacts, 'failed', RbConfig.ruby, '-e', 'exit 47')
      assert_equal 47, status.exitstatus
      assert_equal "47\n", File.read(File.join(artifacts, 'failed-status.txt'))
    end
  end

  def test_diagnostic_errors_do_not_replace_command_failure
    with_runner(collector_status: 99) do |directory, artifacts|
      _output, _error, status = command(directory, artifacts, 'failed', RbConfig.ruby, '-e', 'exit 47')
      assert_equal 47, status.exitstatus
      assert_equal "47\n", File.read(File.join(artifacts, 'failed-status.txt'))
    end
  end

  def test_invalid_labels_are_rejected_before_creating_artifacts
    with_runner do |directory, artifacts|
      _output, _error, status = command(directory, artifacts, '../outside', 'true')
      assert_equal 2, status.exitstatus
      refute File.exist?(artifacts)
    end
  end

  def test_missing_command_is_rejected
    with_runner do |directory, artifacts|
      _output, _error, status = command(directory, artifacts, 'missing')
      assert_equal 2, status.exitstatus
      refute File.exist?(artifacts)
    end
  end

  def test_assertion_is_logged_before_teardown_without_becoming_a_pass
    example = Example.new('exercise')
    example.body_error = Minitest::Assertion.new('original assertion')
    result = nil
    _output, error = capture_io { result = example.run }
    events = error.lines.map { |line| JSON.parse(line.delete_prefix('CI_DEBUG ')) }
    names = events.map { |event| event.fetch('event') }
    assert_equal ['start', 'before_teardown', 'finish'], names
    assert_equal 'original assertion', events[1].fetch('recorded_failures').first.fetch('message')
    assert_equal ['original assertion'], result.failures.map(&:message)
  end

  def test_original_assertion_and_cleanup_error_both_remain_failures
    example = Example.new('exercise')
    example.body_error = Minitest::Assertion.new('original assertion')
    example.teardown_error = RuntimeError.new('cleanup error')
    result = nil
    _output, error = capture_io { result = example.run }
    assert_equal 2, result.failures.size
    assert_match(/original assertion/, result.failures.first.message)
    assert_match(/cleanup error/, result.failures.last.message)
    assert_includes error, '"event":"finish"'
  end

  def test_event_formatting_errors_are_nonfatal
    assert_nil CiDebugEvents.emit('start', Object.new)
  end
end
