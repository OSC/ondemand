require "application_system_test_case"

class FilesTest < ApplicationSystemTestCase
  test "visiting files app doesn't raise js errors" do
    visit files_url(Rails.root.to_s)

    messages = page.driver.browser.manage.logs.get(:browser)
    content = messages.join("\n")
    assert_equal 0, messages.length, "console error messages include:\n\n#{content}\n\n"

    # problem with using capybara and the Rails system tests:
    # https://github.com/rails/rails/issues/39987
    # though supposedly it still works with headless chrome https://github.com/rails/rails/pull/37792
    # but watching it visually makes it easier to debug
  end

  test "visiting files app directory" do
    visit files_url(Rails.root.to_s)
    find('tbody a', exact_text: 'app').ancestor('tr').click
    assert_selector '.selected', count: 1
    find('tbody a', exact_text: 'config').ancestor('tr').click(:meta)
    assert_selector '.selected', count: 2
  end
end
