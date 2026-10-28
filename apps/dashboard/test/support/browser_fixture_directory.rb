# frozen_string_literal: true

# Keep fixtures available for failure screenshots and pending app-server requests.
module BrowserFixtureDirectory
  # Unlike Dir.mktmpdir's block form, leaving this block does not remove the directory.
  # before_teardown owns cleanup so screenshots and browser reset can still use it.
  def with_browser_fixture_directory_until_teardown
    directory = Dir.mktmpdir
    (@browser_fixture_directories ||= []) << directory
    yield directory
  end

  # Keep the original name for existing callers of this shared test helper.
  alias with_browser_fixture_directory with_browser_fixture_directory_until_teardown

  def before_teardown
    # Rails captures failure screenshots here, before the browser is reset.
    super
  ensure
    reset_browser_then_remove_fixture_directories
  end

  private

  def reset_browser_then_remove_fixture_directories
    directories_to_remove = @browser_fixture_directories
    return if directories_to_remove.nil? || directories_to_remove.empty?

    begin
      # Upload completion can start an asynchronous table reload. Reset the browser
      # and wait for pending app-server requests before deleting their fixture paths.
      # Rails' later reset_sessions! in after_teardown runs after this cleanup.
      page.reset!
    ensure
      directories_to_remove.each { |directory| FileUtils.remove_entry(directory) }
      directories_to_remove.clear
    end
  end
end
