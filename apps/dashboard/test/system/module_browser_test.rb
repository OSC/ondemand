# frozen_string_literal: true

require 'application_system_test_case'

class ModuleBrowserTest < ApplicationSystemTestCase
  MODULE_BTN_SELECT = '.module-card button[data-bs-toggle="collapse"]'

  def fixture_dir
    "#{Rails.root}/test/fixtures/modules/"
  end

  def results_text(count)
    "Showing #{count} results"
  end

  setup do
    stub_sys_apps
  end

  test 'searching by module name filters results' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      visit module_browser_url
      initial_count = all('.module-card').count
      
      fill_in 'module_search', with: 'gcc'
      assert_selector('#module_results_count', text: results_text(2))

      all('.module-card', visible: true).each do |card|
        module_name = card['data-name'].downcase
        assert module_name.include?('gcc'), "Expected #{module_name} to include 'gcc'"
      end
      
      fill_in 'module_search', with: ''
      assert_selector('#module_results_count', text: results_text(initial_count))
      
      final_count = all('.module-card', visible: true).count
      assert_equal initial_count, final_count
    end
  end

  test 'filtering by cluster only shows supported modules' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      visit module_browser_url
      
      cluster_options = all('#cluster_filter option').to_a
      initial_count = all('.module-card', visible: true).count
      
      first_cluster = cluster_options[1]
      cluster_id = first_cluster.value
      
      select first_cluster.text, from: 'cluster_filter'
      
      all('.module-card', visible: true).each do |card|
        clusters = card['data-clusters'].split(',')
        assert clusters.include?(cluster_id), "Module should have #{cluster_id} in its cluster list"
      end

      select 'All Clusters', from: 'cluster_filter'
      
      final_count = all('.module-card', visible: true).count
      assert_equal initial_count, final_count
    end
  end

  test 'module button expands and collapses the module details' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      visit module_browser_url

      first_module = find(MODULE_BTN_SELECT, match: :first)
      collapse_id = first_module['data-bs-target']
      
      assert_selector("#{collapse_id}", visible: :hidden)
      
      first_module.click
      assert_selector("#{MODULE_BTN_SELECT}.active")
      assert_selector("#{collapse_id}", visible: :visible)
      
      first_module.click
      assert_selector("#{MODULE_BTN_SELECT}.collapsed")
      assert_selector("#{collapse_id}", visible: :hidden)
    end
  end

  test 'selecting a version updates the load command' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      visit module_browser_url
      
      first_module = find(MODULE_BTN_SELECT, match: :first)
      first_module.click

      assert_selector("#{MODULE_BTN_SELECT}.active")
      version_button = find('button[data-role="selectable-version"]', match: :first)
      module_name = version_button['data-module']
      version = version_button['data-version']
      
      refute version_button.matches_css?('.active')
      version_button.click
      assert version_button.matches_css?('.active')
      
      load_cmd = find('[data-role="module-load-command"]')
      expected_text = "module load #{module_name}/#{version}"
      assert_equal expected_text, load_cmd.text.strip
    end
  end

  test 'updates results count when filtering' do
    with_modified_env({ OOD_MODULE_FILE_DIR: fixture_dir }) do
      visit module_browser_url
      initial_count = all('.module-card', visible: true).count
      initial_count_text = find('#module_results_count').text

      assert_equal "Showing #{initial_count} results", initial_count_text
      
      fill_in 'module_search', with: 'nonexistent_module'
      assert_selector('#module_results_count', text: results_text(0))
    end
  end
end
