# frozen_string_literal: true

# Retain fixtures through Rails' failure screenshot, then reset before removal.
module BrowserFixtureDirectory
  # Fixtures intentionally live until teardown, rather than just this block.
  def with_browser_fixture_directory
    directory = Dir.mktmpdir
    (@browser_fixture_directories ||= []) << directory
    yield directory
  end

  # Rails takes failure screenshots and resets Capybara before fixture removal.
  def after_teardown
    super
  ensure
    Array(@browser_fixture_directories).each { |directory| FileUtils.remove_entry(directory) }
  end
end
