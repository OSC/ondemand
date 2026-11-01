# frozen_string_literal: true

require 'application_system_test_case'

class ModuleBrowserTest < ApplicationSystemTestCase
  MODULE_BTN_SELECT = '.module-card button[data-bs-toggle="collapse"]'
  VERSION_BTN_SELECT = 'button[data-role="selectable-version"]'
  ALL_MODULES = ['gcc', 'gcc-tools', 'openmpi', 'python'].freeze

  setup do
    stub_sys_apps
    # The JSON loader behind HpcModule.all is covered in test/models/hpc_module_test.rb.
    HpcModule.stubs(:all).returns([
      HpcModule.new('gcc', version: '12.2', cluster: :owens),
      HpcModule.new('gcc-tools', version: '1.0', cluster: :owens),
      HpcModule.new('python', version: '3.11', cluster: :owens),
      HpcModule.new('gcc', version: '11.3', cluster: :oakley),
      HpcModule.new('openmpi', version: '4.1', cluster: :oakley)
    ])
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
    select 'Owens', from: 'cluster_filter'
    assert_modules(['gcc', 'gcc-tools', 'python'])

    select 'Oakley', from: 'cluster_filter'
    assert_modules(['gcc', 'openmpi'])

    select 'All Clusters', from: 'cluster_filter'
    assert_modules(ALL_MODULES)
  end

  test 'search and cluster filters apply together' do
    fill_in 'module_search', with: 'gcc'
    assert_modules(['gcc', 'gcc-tools'])

    select 'Oakley', from: 'cluster_filter'
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

    version_button = find(VERSION_BTN_SELECT, match: :first)
    module_name = version_button['data-module']
    version = version_button['data-version']

    assert_no_selector("#{VERSION_BTN_SELECT}.active")
    version_button.click
    assert_selector("#{VERSION_BTN_SELECT}.active", exact_text: version)
    assert_selector('[data-role="module-load-command"]', exact_text: "module load #{module_name}/#{version}")
  end

  private

  # Filtering updates the count and card visibility in the same synchronous pass,
  # so once the count text matches, the visible cards are final.
  def assert_modules(names)
    assert_selector('#module_results_count', exact_text: "Showing #{names.size} results")
    shown = all('.module-card', count: names.size).map { |card| card['data-name'] }
    assert_equal(names.sort, shown.sort)
  end
end
