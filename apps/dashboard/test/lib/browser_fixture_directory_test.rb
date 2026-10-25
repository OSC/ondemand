# frozen_string_literal: true

require 'test_helper'
require_relative '../support/browser_fixture_directory'

# Verify cleanup ordering on both successful and failing browser examples.
class BrowserFixtureDirectoryTest < ActiveSupport::TestCase
  include BrowserFixtureDirectory

  attr_reader :page

  def prepare_page(&reset)
    @page = Object.new
    @page.define_singleton_method(:reset!) { reset.call }
  end

  test 'reset happens while fixture files still exist' do
    directory = nil
    reset = false
    prepare_page do
      assert File.file?(File.join(directory, 'record'))
      reset = true
    end
    with_browser_fixture_directory do |path|
      directory = path
      File.write(File.join(path, 'record'), 'data')
    end
    assert reset
    refute File.exist?(directory)
  end

  test 'a failed example still resets before removing fixtures' do
    directory = nil
    reset = false
    prepare_page do
      assert File.directory?(directory)
      reset = true
    end
    error = assert_raises(RuntimeError) do
      with_browser_fixture_directory do |path|
        directory = path
        raise 'example failure'
      end
    end
    assert_equal 'example failure', error.message
    assert reset
    refute File.exist?(directory)
  end

  test 'fixture cleanup still runs if browser reset fails' do
    directory = nil
    prepare_page { raise 'reset failure' }
    assert_raises(RuntimeError) do
      with_browser_fixture_directory { |path| directory = path }
    end
    refute File.exist?(directory)
  end
end
