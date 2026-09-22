# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

# ChromeDriver can report a selector candidate from a replaced document as
# UnknownError instead of StaleElementReferenceError while Capybara checks
# visibility. A detached candidate cannot satisfy the current selector, so
# treat only this known Chrome condition as a non-match and let Capybara's
# surrounding synchronized query resolve against the current document.
#
# Keep this workaround at the visibility-filter boundary. Broadening
# Node::Base#synchronize or driver.invalid_element_errors could retry
# side-effecting actions or hide unrelated browser failures.
#
# Remove this shim only after OOD verifies that its supported
# Capybara/ChromeDriver combination no longer reproduces the failure without it.
#
# See OSC/ondemand#4725, teamcapybara/capybara#2800, and
# SeleniumHQ/selenium#15401.
module CapybaraChromeDetachedDocumentVisibilityRetry
  DETACHED_DOCUMENT_ERROR_MESSAGE = 'Node with given id does not belong to the document'
  SUPPORTED_CAPYBARA_VERSION = '3.40.0'
  EXPECTED_VISIBILITY_FILTER_PARAMETERS = [[:req, :node]].freeze

  private

  def matches_visibility_filters?(node)
    super
  rescue Selenium::WebDriver::Error::UnknownError => error
    raise unless chrome_detached_document_error?(node, error)

    false
  end

  def chrome_detached_document_error?(node, error)
    node.respond_to?(:base) &&
      node.base.is_a?(Capybara::Selenium::ChromeNode) &&
      error.message.include?(DETACHED_DOCUMENT_ERROR_MESSAGE)
  end
end

supported_capybara = CapybaraChromeDetachedDocumentVisibilityRetry::SUPPORTED_CAPYBARA_VERSION
unless Capybara::VERSION == supported_capybara
  raise "Review Chrome detached-document visibility retry for Capybara #{Capybara::VERSION}: " \
        "workaround was validated against Capybara #{supported_capybara}"
end

if Capybara::Selenium::ChromeNode.protected_instance_methods(false).include?(:catch_error?)
  raise "Review Chrome detached-document visibility retry for Capybara #{Capybara::VERSION}: " \
        'ChromeNode now defines its own catch_error? handling'
end

visibility_filter = Capybara::Queries::SelectorQuery.instance_method(:matches_visibility_filters?)
expected_parameters = CapybaraChromeDetachedDocumentVisibilityRetry::EXPECTED_VISIBILITY_FILTER_PARAMETERS
unless visibility_filter.parameters == expected_parameters
  raise "Review Chrome detached-document visibility retry for Capybara #{Capybara::VERSION}: " \
        'SelectorQuery#matches_visibility_filters? signature changed'
end

unless Capybara::Queries::SelectorQuery.ancestors.include?(CapybaraChromeDetachedDocumentVisibilityRetry)
  Capybara::Queries::SelectorQuery.prepend(CapybaraChromeDetachedDocumentVisibilityRetry)
end
