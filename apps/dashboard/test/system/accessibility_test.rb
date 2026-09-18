require 'application_system_test_case'

class AccessibilityTest < ApplicationSystemTestCase
  # Yield one browser event-loop turn so MutationObserver callbacks can run.
  MUTATION_OBSERVER_TURN_SCRIPT = 'setTimeout(arguments[arguments.length - 1], 0)'.freeze

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
    visit files_url(Rails.root.to_s)
    text = find('#directory-contents_info')
    text.execute_script('this.style = "color: darkseagreen"')
    page.evaluate_async_script(MUTATION_OBSERVER_TURN_SCRIPT)
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      find('#path-breadcrumbs')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(143, 188, 143\)"/, error.message)
    assert_match(/"bg":"rgb\(255, 255, 255\)"/, error.message)
    assert_match(/"ratio":2\.15/, error.message)
    assert_match(/"tag":"DIV"/, error.message)
  end

  test 'contrast watcher detects violations from class changes' do
    visit files_url(Rails.root.to_s)
    button = find('#path-breadcrumbs')
    button.execute_script('this.classList.add("bg-danger")')
    page.evaluate_async_script(MUTATION_OBSERVER_TURN_SCRIPT)
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      find('#path-breadcrumbs')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(31, 110, 178\)"/, error.message)
    assert_match(/"bg":"rgb\(220, 53, 69\)"/, error.message)
    assert_match(/"ratio":1\.18/, error.message)
    assert_match(/"tag":"A"/, error.message)
  end

  test 'element with css transition' do
    visit files_url(Rails.root.to_s)
    button = find('#copy-move-btn')
    button.execute_script('this.classList.add("bg-danger")')
    page.evaluate_async_script(MUTATION_OBSERVER_TURN_SCRIPT)
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      find('#copy-move-btn')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(33, 37, 41\)"/, error.message)
    assert_match(/"bg":"rgb\(220, 53, 69\)"/, error.message)
    assert_match(/"ratio":3\.41/, error.message)
    assert_match(/"tag":"BUTTON"/, error.message)
  end

  test 'contrast watcher detects violations from inserted elements' do
    NEW_ELEMENT_SCRIPT = <<~HEREDOC
      span = document.createElement('span');
      span.id = 'contrast_test_element';
      span.textContent = 'NEW ELEMENT';
      span.style = 'color: lightgrey';
      document.getElementById('main_container').appendChild(span);
    HEREDOC
    visit('/')
    page.execute_script(NEW_ELEMENT_SCRIPT)
    page.assert_selector('#contrast_test_element')
    page.evaluate_async_script(MUTATION_OBSERVER_TURN_SCRIPT)
    error = assert_raises(Selenium::WebDriver::Error::JavascriptError) do
      assert_selector('#main_container')
    end
    assert_match(/Contrast check failed/, error.message)
    assert_match(/"fg":"rgb\(211, 211, 211\)"/, error.message)
    assert_match(/"bg":"rgb\(255, 255, 255\)"/, error.message)
    assert_match(/"ratio":1\.5/, error.message)
    assert_match(/"tag":"SPAN"/, error.message)
  end
end
