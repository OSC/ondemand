require 'application_system_test_case'

class AccessibilityTest < ApplicationSystemTestCase
  test 'contrast watcher detects violations on page load' do
    with_modified_env(OOD_BRAND_BG_COLOR: 'cadetblue') do 
      error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
        visit('/')
      end
      assert_match(/Contrast check failed/, error.message)
      assert_match(/"fg":"rgb\(255, 255, 255\)"/, error.message)
      assert_match(/"bg":"rgb\(95, 158, 160\)"/, error.message)
      assert_match(/"ratio":3\.05/, error.message)
      assert_match(/"tag":"SPAN"/, error.message)
    end
  end

  test 'contrast watcher detects violations from style changes' do
  end

  test 'contrast watcher detects violations from class changes' do
    visit files_url(Rails.root.to_s)
    button = find('#path-breadcrumbs')
    button.execute_script('this.classList.add("bg-danger")')
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      find('#path-breadcrumbs')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(31, 110, 178\)"/, error.message)
    assert_match(/"bg":"rgb\(220, 53, 69\)"/, error.message)
    assert_match(/"ratio":1\.18/, error.message)
    assert_match(/"tag":"A"/, error.message)
  end

  test 'weird button case' do
    visit files_url(Rails.root.to_s)
    button = find('#copy-move-btn')
    button.execute_script('this.classList.add("bg-danger")')
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      # find any element on the page to check script status
      find('#copy-move-btn')
      # puts evaluate_script('window.__contrastViolations')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(255, 255, 255\)"/, error.message)
    assert_match(/"bg":"rgb\(95, 158, 160\)"/, error.message)
    assert_match(/"ratio":3\.05/, error.message)
    assert_match(/"tag":"STRONG"/, error.message)
  end

  test 'contrast watcher detects violations from inserted elements' do 
  end
end
