# frozen_string_literal: true

require 'application_system_test_case'

# Exercise real module filtering against a small, isolated spider-output fixture.
class ModuleBrowserTest < ApplicationSystemTestCase
  MODULE_BTN_SELECT = '.module-card button[data-bs-toggle="collapse"]'
  MODULE_NAMES = ['gcc', 'gcc-tools', 'openmpi', 'python'].freeze
  CLUSTER_MODULES = {
    'owens'  => ['gcc', 'gcc-tools', 'python'],
    'oakley' => ['gcc', 'openmpi']
  }.freeze

  setup do
    stub_sys_apps
    Configuration.stubs(:module_file_dir).returns(Rails.root.join('test/fixtures/modules/browser'))
    clear_module_cache
  end

  teardown do
    # Drain requests while the fixture configuration and cluster stubs still apply.
    page.reset!
  ensure
    clear_module_cache
  end

  test 'searching by module name filters results' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    fill_in 'module_search', with: 'GCC'
    assert_module_results(['gcc', 'gcc-tools'], search: 'GCC')

    fill_in 'module_search', with: ''
    assert_module_results(MODULE_NAMES)
  end

  test 'filtering by cluster only shows supported modules' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    CLUSTER_MODULES.each do |cluster, names|
      find("#cluster_filter option[value='#{cluster}']").select_option
      assert_module_results(names, cluster: cluster)
    end

    find('#cluster_filter option[value=""]').select_option
    assert_module_results(MODULE_NAMES)
  end

  test 'search and cluster filters apply together' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    fill_in 'module_search', with: 'gcc'
    assert_module_results(['gcc', 'gcc-tools'], search: 'gcc')
    find('#cluster_filter option[value="oakley"]').select_option
    assert_module_results(['gcc'], search: 'gcc', cluster: 'oakley')

    fill_in 'module_search', with: 'python'
    assert_module_results([], search: 'python', cluster: 'oakley')
    find('#cluster_filter option[value="owens"]').select_option
    assert_module_results(['python'], search: 'python', cluster: 'owens')

    fill_in 'module_search', with: ''
    assert_module_results(CLUSTER_MODULES.fetch('owens'), cluster: 'owens')
    find('#cluster_filter option[value=""]').select_option
    assert_module_results(MODULE_NAMES)
  end

  test 'rapid searches use the latest input' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    # Dispatch inputs in one browser turn, before any debounce timer can fire.
    execute_script <<~JS
      const search = document.getElementById('module_search');
      ['gcc', 'no-such-module', 'PYTHON'].forEach(value => {
        search.value = value;
        search.dispatchEvent(new Event('input', { bubbles: true }));
      });
    JS
    assert_module_results(['python'], search: 'PYTHON')
  end

  test 'module button expands and collapses the module details' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    first_module = find(MODULE_BTN_SELECT, match: :first)
    collapse_id = first_module['data-bs-target']

    assert_selector(collapse_id, visible: :hidden)
    first_module.click
    assert_selector("#{MODULE_BTN_SELECT}.active")
    assert_selector(collapse_id, visible: :visible)

    first_module.click
    assert_selector("#{MODULE_BTN_SELECT}.collapsed")
    assert_selector(collapse_id, visible: :hidden)
  end

  test 'selecting a version updates the load command' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    first_module = find(MODULE_BTN_SELECT, match: :first)
    first_module.click
    assert_selector("#{MODULE_BTN_SELECT}.active")
    version_button = find('button[data-role="selectable-version"]', match: :first)
    module_name = version_button['data-module']
    version = version_button['data-version']

    refute version_button.matches_css?('.active')
    version_button.click
    assert_selector('button[data-role="selectable-version"].active', text: version, exact_text: true)
    assert_selector('[data-role="module-load-command"]', exact_text: "module load #{module_name}/#{version}")
  end

  test 'updates results count when filtering' do
    visit module_browser_url
    assert_module_results(MODULE_NAMES)

    fill_in 'module_search', with: 'nonexistent_module'
    assert_module_results([], search: 'nonexistent_module')

    fill_in 'module_search', with: ''
    assert_module_results(MODULE_NAMES)
  end

  private

  def clear_module_cache
    CLUSTER_MODULES.each_key { |cluster| Rails.cache.delete("modules_#{cluster}") }
  end

  # Compare known identities and count in one observation, including initial load.
  def assert_module_results(names, search: '', cluster: '')
    expected = {
      'all'     => MODULE_NAMES.sort,
      'visible' => names.sort,
      'count'   => "Showing #{names.size} results",
      'search'  => search,
      'cluster' => cluster
    }
    snapshot = nil
    page.document.synchronize(errors: [Capybara::ExpectationNotMet]) do
      snapshot = evaluate_script <<~JS
        (() => {
          const cards = Array.from(document.querySelectorAll('.module-card'));
          const visible = cards.filter(card =>
            card.getClientRects().length > 0 && getComputedStyle(card).visibility !== 'hidden');
          return {
            all: cards.map(card => card.dataset.name).sort(),
            visible: visible.map(card => card.dataset.name).sort(),
            count: document.getElementById('module_results_count').textContent.trim(),
            search: document.getElementById('module_search').value,
            cluster: document.getElementById('cluster_filter').value
          };
        })()
      JS
      unless snapshot == expected
        raise Capybara::ExpectationNotMet, "Expected #{expected.inspect}; observed #{snapshot.inspect}"
      end
    end
    assert_equal expected, snapshot
  rescue Capybara::ExpectationNotMet => e
    flunk e.message
  end
end
