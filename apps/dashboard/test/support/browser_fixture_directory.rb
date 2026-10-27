# frozen_string_literal: true

# Retain fixtures until browser reset waits for pending app-server requests.
module BrowserFixtureDirectory
  # Fixtures intentionally live until teardown, rather than just this block.
  def with_browser_fixture_directory
    directory = Dir.mktmpdir
    (@browser_fixture_directories ||= []) << directory
    yield directory
  end

  def before_teardown
    super
  ensure
    remove_browser_fixture_directories
  end

  private

  def remove_browser_fixture_directories
    directories = @browser_fixture_directories
    return if directories.nil? || directories.empty?

    begin
      # Rails resets sessions again in after_teardown; reset early while fixtures exist.
      page.reset!
    ensure
      directories.each { |directory| FileUtils.remove_entry(directory) }
      directories.clear
    end
  end
end
