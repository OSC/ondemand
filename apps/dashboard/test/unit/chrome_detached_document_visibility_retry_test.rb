# frozen_string_literal: true

require 'test_helper'
require 'chrome_detached_document_visibility_retry'

class ChromeDetachedDocumentVisibilityRetryTest < ActiveSupport::TestCase
  FakeDriver = Struct.new(:invalid_element_errors)

  class FakeSession
    attr_reader :driver

    def initialize(driver)
      @driver = driver
    end

    def using_wait_time(_seconds)
      yield
    end
  end

  class FakeNode
    attr_reader :base, :initial_cache, :session

    def initialize(base:, error: nil, visible: true, obscured_error: nil, invalid_element_errors: [])
      @base = base
      @error = error
      @visible = visible
      @obscured_error = obscured_error
      @initial_cache = {}
      @session = FakeSession.new(FakeDriver.new(invalid_element_errors))
    end

    def visible?
      raise @error if @error

      @visible
    end

    def obscured?
      raise @obscured_error if @obscured_error

      false
    end
  end

  def query(visible: true, obscured: nil, &filter_block)
    options = {
      visible: visible,
      session_options: Capybara.session_options
    }
    options[:obscured] = obscured unless obscured.nil?

    Capybara::Queries::SelectorQuery.new(:css, '.candidate', **options, &filter_block)
  end

  def chrome_base
    Capybara::Selenium::ChromeNode.allocate
  end

  def non_chrome_base
    Object.new
  end

  def detached_document_error(prefix = 'unknown error: ')
    Selenium::WebDriver::Error::UnknownError.new(
      "#{prefix}#{CapybaraChromeDetachedDocumentVisibilityRetry::DETACHED_DOCUMENT_ERROR_MESSAGE}"
    )
  end

  test 'treats Chrome detached-document visibility error as a stale selector candidate' do
    node = FakeNode.new(base: chrome_base, error: detached_document_error)

    assert_equal false, query.matches_filters?(node)
  end

  test 'does not depend on inspector error JSON formatting' do
    node = FakeNode.new(base: chrome_base, error: detached_document_error(''))

    assert_equal false, query.matches_filters?(node)
  end

  test 'does not swallow unrelated Chrome UnknownError' do
    error = Selenium::WebDriver::Error::UnknownError.new('different ChromeDriver failure')
    node = FakeNode.new(base: chrome_base, error: error)

    raised = assert_raises(Selenium::WebDriver::Error::UnknownError) do
      query.matches_filters?(node)
    end

    assert_same error, raised
  end

  test 'does not make UnknownError generally retryable' do
    driver = Capybara::Selenium::Driver.allocate

    refute_includes driver.invalid_element_errors, Selenium::WebDriver::Error::UnknownError
  end

  test 'does not swallow the same message from a non-Chrome selector candidate' do
    error = detached_document_error
    node = FakeNode.new(base: non_chrome_base, error: error)

    raised = assert_raises(Selenium::WebDriver::Error::UnknownError) do
      query.matches_filters?(node)
    end

    assert_same error, raised
  end

  test 'does not swallow the same message from a custom selector filter' do
    error = detached_document_error
    node = FakeNode.new(base: chrome_base)

    raised = assert_raises(Selenium::WebDriver::Error::UnknownError) do
      query { raise error }.matches_filters?(node)
    end

    assert_same error, raised
  end

  test 'preserves Capybara standard stale-element selector behavior' do
    error = Selenium::WebDriver::Error::StaleElementReferenceError.new('stale element')
    node = FakeNode.new(
      base: chrome_base,
      error: error,
      invalid_element_errors: [Selenium::WebDriver::Error::StaleElementReferenceError]
    )

    assert_equal false, query.matches_filters?(node)
  end

  test 'preserves successful visible selector matches' do
    node = FakeNode.new(base: chrome_base)

    assert_equal true, query.matches_filters?(node)
  end

  test 'preserves visible all without consulting visibility' do
    node = FakeNode.new(base: chrome_base, error: detached_document_error)

    assert_equal true, query(visible: false).matches_filters?(node)
  end

  test 'treats detached Chrome errors from obscured checks as stale candidates' do
    node = FakeNode.new(base: chrome_base, obscured_error: detached_document_error)

    assert_equal false, query(obscured: false).matches_filters?(node)
  end
end
