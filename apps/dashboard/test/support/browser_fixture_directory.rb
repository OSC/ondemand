# frozen_string_literal: true

# Stop browser polling and drain requests before removing their backing files.
module BrowserFixtureDirectory
  def with_browser_fixture_directory
    Dir.mktmpdir do |directory|
      yield directory
    ensure
      page.reset!
    end
  end
end
