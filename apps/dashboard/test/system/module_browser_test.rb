# frozen_string_literal: true

require 'application_system_test_case'

class ModuleBrowserTest < ApplicationSystemTestCase
  MODULE_BTN_SELECT = '.module-card button[data-bs-toggle="collapse"]'
  ALL_MODULES = ['gcc', 'gcc-tools', 'openmpi', 'python'].freeze

  setup do
    stub_sys_apps
    # owens: gcc, gcc-tools, python; oakley: gcc, openmpi
    Configuration.stubs(:module_file_dir).returns(Rails.root.join('test/fixtures/modules/browser').to_s)
    visit module_browser_url
  end

  test 'searching by module name filters results' do
    assert_modules(ALL_MODULES)

    fill_in 'module_search', with: 'GCC'
    assert_modules(['gcc', 'gcc-tools'])

    fill_in 'module_search', with: 'nonexistent_module'
    assert_modules([])

    fill_in 'module_search', with: ''
    assert_modules(ALL_MODULES)
  end

  test 'filtering by cluster only shows supported modules' do
    find('#cluster_filter option[value="owens"]').select_option
    assert_modules(['gcc', 'gcc-tools', 'python'])

    find('#cluster_filter option[value="oakley"]').select_option
    assert_modules(['gcc', 'openmpi'])

    find('#cluster_filter option[value=""]').select_option
    assert_modules(ALL_MODULES)
  end

  test 'search and cluster filters apply together' do
    fill_in 'module_search', with: 'gcc'
    assert_modules(['gcc', 'gcc-tools'])

    find('#cluster_filter option[value="oakley"]').select_option
    assert_modules(['gcc'])
  end

  test 'module button expands and collapses the module details' do
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
    find(MODULE_BTN_SELECT, match: :first).click
    assert_selector("#{MODULE_BTN_SELECT}.active")

    version_button = find('button[data-role="selectable-version"]', match: :first)
    module_name = version_button['data-module']
    version = version_button['data-version']

    # not_matches_css? returns at once; refute matches_css? waits out the full timeout.
    assert version_button.not_matches_css?('.active')
    version_button.click
    assert_selector('button[data-role="selectable-version"].active', exact_text: version)
    assert_selector('[data-role="module-load-command"]', exact_text: "module load #{module_name}/#{version}")
  end

  private

  # Filtering updates the count and card visibility in the same synchronous pass,
  # so once the count text matches, the visible cards are final.
  def assert_modules(names)
    assert_selector('#module_results_count', exact_text: "Showing #{names.size} results")
    shown = all('.module-card', count: names.size).map { |card| card['data-name'] }
    assert_equal(names, shown.sort)
  end
end
